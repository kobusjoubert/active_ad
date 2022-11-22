class ActiveAd::Relation
  # The Enumerable mixin provides collection classes with several traversal and searching methods, and with the ability to sort. The class must provide a
  # method each, which yields successive members of the collection. If #max, min, or sort is used, the objects in the collection must also implement a
  # meaningful <=> operator, as these methods rely on an ordering between members of the collection.
  include Enumerable
  include ActiveAd::Requestable

  Response = Struct.new(:success?, :body)

  attr_reader :klass, :kwargs, :client, :strategy, :limit_value, :offset_value, :next_offset_value

  def initialize(klass, **kwargs)
    raise ArgumentError, 'missing keyword: :client' unless (client = kwargs.delete(:client))

    @klass = klass
    @kwargs = kwargs
    @limit_value = Float::INFINITY
    @offset_value = nil
    @next_offset_value = nil
    @client = client
    @strategy = client.pagination_type # :offset, :cursor, :relay_cursor
    @model_type = klass.to_s.split('::').last.underscore.to_sym # :account, :campaign, :ad_group, :ad
  end

  # Calling `dup` or `clone` on an object creates a shallow copy of the object. Instance variables are copied, but not the objects they reference. So complex
  # data structures like arrays, hashes and objects are copied by reference, and will change when being changed from another cloned copy. The `initialize_dup`
  # and `initialize_clone` ruby methods allow us to deep duplicate any complex data structures that matter.
  def initialize_dup(_)
    @kwargs = @kwargs.dup
    reset
    super
  end

  def initialize_clone(_)
    @kwargs = @kwargs.clone
    reset
    super
  end

  # Returns an Enumerator.
  def each
    return to_enum(:each) unless block_given?

    index = 0
    total = 0

    loop do
      ActiveAd.logger.debug("ActiveAd::Relation#each looping at index: #{index}")

      unless index_response.success?
        ActiveAd.raise_relational_errors ? raise(ActiveAd::RelationNotFound.new(self, index_response)) : break
      end

      attributes = index_response_data(index)

      if attributes
        attributes.merge!(relational_attributes)
        yield new_object(attributes)
        index += 1
      else
        break if index.zero?

        @next_offset_value = index_response_offset.values.first
        break unless next_offset_value

        request_kwargs = kwargs.merge(index_response_offset)
        ActiveAd.logger.debug("Calling index_request with kwargs: #{request_kwargs}")
        @_index_response = request(klass.index_request(client:, **request_kwargs))
        index = 0
      end

      total += 1
      break if total >= limit_value
    end
  end

  # TODO: Implement in subclasses with a smaller request payload.
  def size
    count
  end

  def limit(value)
    clone.limit!(value)
  end

  def limit!(value)
    @limit_value = value
    self
  end

  def offset(value)
    clone.offset!(value)
  end

  def offset!(value)
    @offset_value = value
    self
  end

  # # TODO: Implement a more efficient count_request method.
  # def count
  #   super
  # end

  # Returns an ActiveAd::Relation with updated `@kwargs`. Changes are appended.
  #
  # === Example
  #
  #   scope = campaign.where(account_id: '123', status: ['PAUSED']) # => kwargs: { account_id: '123', status: ['PAUSED'] }
  #   scope = scope.where(account_id: '123', status: ['DELETED'])   # => kwargs: { account_id: '123', status: ['PAUSED', 'DELETED'] }
  #   scope = scope.where(account_id: '456', status: ['PAUSED'])    # => kwargs: { account_id: '456', status: ['PAUSED', 'DELETED'] }
  def where(**kwargs)
    clone.where!(**kwargs)
  end

  def where!(**kwargs)
    @kwargs.merge!(kwargs) do |_key, old_value, new_value|
      if old_value.is_a?(Array) && new_value.is_a?(Array)
        (old_value + new_value).uniq
      else
        new_value
      end
    end

    self
  end

  # Returns an ActiveAd::Relation with updated `@kwargs`. Changes are overwritten.
  #
  # === Example
  #
  #   scope = campaign.where(account_id: '123', status: ['PAUSED']) # => kwargs: { account_id: '123', status: ['PAUSED'] }
  #   scope = scope.rewhere(status: ['DELETED'])                    # => kwargs: { account_id: '123', status: ['DELETED'] }
  #   scope = scope.rewhere(account_id: '456', status: ['PAUSED'])  # => kwargs: { account_id: '456', status: ['PAUSED'] }
  def rewhere(**kwargs)
    clone.rewhere!(**kwargs)
  end

  def rewhere!(**kwargs)
    @kwargs.merge!(kwargs)
    self
  end

  private

  # Cursor based pagination.
  #
  # Uses the `limit` and `after` query parameters.
  #
  # Platforms using this approach: Facebook.
  #
  # === Example
  #
  #   https://somewhere.com/resources?limit=10&after=a1b2c3
  #
  # === Response
  #
  # {
  #   "data": [{
  #      ...
  #   }],
  #   "paging": {
  #     "cursors": {
  #       "after": "MTAxNTExOTQ1MjAwNzI5NDE=",
  #       "before": "NDMyNzQyODI3OTQw"
  #     },
  #     "previous": "https://somewhere.com/resources?limit=25&before=NDMyNzQyODI3OTQw", # Only present if it exists.
  #     "next": "https://somewhere.com/resources?limit=25&after=MTAxNTExOTQ1MjAwNzI5NDE=" # Only present if it exists.
  #   }
  # }
  #
  # === Error
  #
  # {
  #   "error": {
  #     "message": "no no no"
  #   }
  # }

  def reset
    @_index_response = nil
    @next_offset_value = nil
  end

  # Invalidate cache when reaching the end of the current list and paginating over to the next set of results. Add `limit` and `offset` parameters to the API
  # calls when supplied.
  def index_response
    kwargs.merge!(index_request_limit) unless limit_value.infinite?
    kwargs.merge!(index_request_offset) if offset_value

    @_index_response ||= begin
      ActiveAd.logger.debug("Calling index_request with kwargs: #{kwargs}")
      request(klass.index_request(client:, **kwargs))
    end
  end

  # TODO: Maybe move the different strategies into their own modules.

  def index_response_data(index)
    case strategy
    when :cursor
      @next_offset_value = index_response_offset.values.first
      index_response.body['data'][index]
    when :offset
      # index_response.body['data'][index]
    end
  end

  def index_response_offset
    case strategy
    when :cursor
      { after: index_response.body.dig('paging', 'cursors', 'after') }
    when :offset
      # { offset: index_response.body.dig('paging', 'page').to_i * limit_value }
    end
  end

  def index_request_limit
    case strategy
    when :cursor
      { limit: limit_value }
    when :offset
      # { offset: limit_value }
    end
  end

  def index_request_offset
    case strategy
    when :cursor
      { after: offset_value }
    when :offset
      # { offset: offset_value }
    end
  end

  # Set the relationships between the objects so that we can call the parent object. For instance when a campaign class has the `belongs_to :account`
  # relationship setup, we'll need to set the `account_id` attribute for `campaign.account` to work.
  def relational_attributes
    attributes = kwargs.dup.deep_stringify_keys
    attributes.keep_if { |key, _| key.include?('_id') && klass.public_method_defined?(key.chomp('_id')) }
  end

  def new_object(attributes)
    response = Response.new(true, attributes)
    object = klass.new(client:, **attributes)

    object.run_callbacks(:find) do
      object.instance_variable_set(:@response, response)
    end

    object.send(:assign_attributes, response.body)
    object.clear_changes_information
    object
  end
end
