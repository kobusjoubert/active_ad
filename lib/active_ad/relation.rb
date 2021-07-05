class ActiveAd::Relation
  # The Enumerable mixin provides collection classes with several traversal and searching methods, and with the ability to sort. The class must provide a
  # method each, which yields successive members of the collection. If #max, min, or sort is used, the objects in the collection must also implement a
  # meaningful <=> operator, as these methods rely on an ordering between members of the collection.
  include Enumerable

  attr_reader :klass, :kwargs, :strategy

  def initialize(klass, **kwargs)
    @klass = klass
    @kwargs = kwargs
    @limit = Float::INFINITY
    @strategy = klass.client.pagination_type # :offset, :cursor, :relay_cursor

    if klass.const_defined?('ATTRIBUTES_MAPPING')
      kwargs.deep_transform_keys! do |key|
        klass::ATTRIBUTES_MAPPING.values.include?(key.to_sym) ? klass::ATTRIBUTES_MAPPING.key(key.to_sym) : key
      end
    end

    # model_type = klass.to_s.split('::').last.underscore.to_sym # :account, :campaign, :ad_group, :ad
  end

  # Returns an Enumerator.
  def each
    return to_enum(:each) unless block_given?

    index = 0
    total = 0

    loop do
      ActiveAd.logger.debug("ActiveAd::Relation each looping at index: #{index}")
      break if total >= @limit

      raise index_response_error.to_s unless index_response.success?

      attributes = index_response_data(index)

      if attributes
        object = klass.new(**attributes)
        yield object
      else
        index = 0
        offset = index_response_offset
        break if offset.values.last.blank?

        request_kwargs = kwargs.merge(offset)
        ActiveAd.logger.info("Calling index_request with kwargs: #{request_kwargs}")
        @_index_response = klass.index_request(**request_kwargs)
      end

      index += 1
      total += 1
    end
  end

  def limit(value)
    @limit = value.to_i
    self
  end

  # TODO: Implement a more efficient count_request method.
  def count
    super
  end

  # Returns an ActiveAd::Relation with updated `@kwargs` ready with swapped keys to be sent to the external API. Changes are appended.
  #
  # === Example
  #
  #   campaign.where(account_id: '123, 'status: ['PAUSED'])  # => kwargs: { account_id: '123', effective_status: ['PAUSED'] }
  #   campaign.where(account_id: '123, 'status: ['DELETED']) # => kwargs: { account_id: '123', effective_status: ['PAUSED', 'DELETED'] }
  #   campaign.where(account_id: '456, 'status: ['PAUSED'])  # => kwargs: { account_id: '456', effective_status: ['PAUSED', 'DELETED'] }
  def where(**kwargs)
    @kwargs.merge!(kwargs_swapped(klass, **kwargs)) do |key, old_value, new_value|
      if old_value.is_a?(Array) && new_value.is_a?(Array)
        (old_value + new_value).uniq
      else
        new_value
      end
    end

    self
  end

  # Returns an ActiveAd::Relation with updated `@kwargs` ready with swapped keys to be sent to the external API. Changes are overwritten.
  #
  # === Example
  #
  #   campaign.where(account_id: '123, 'status: ['PAUSED'])   # => kwargs: { account_id: '123', effective_status: ['PAUSED'] }
  #   campaign.rewhere(status: ['DELETED'])                   # => kwargs: { account_id: '123', status: ['DELETED'] }
  #   campaign.rewhere(account_id: '456, 'status: ['PAUSED']) # => kwargs: { account_id: '456', effective_status: ['PAUSED'] }
  def rewhere(**kwargs)
    @kwargs.merge!(kwargs_swapped(klass, **kwargs))
    self
  end

  private

  # Exchange attribute keys to map what the external API expects.
  #
  #   kwargs         => { "name" => "My Campaign", "status" => "PAUSED" }
  #   kwargs_swapped => { "name" => "My Campaign", "effective_status" => "PAUSED" }
  def kwargs_swapped(klass, **kwargs)
    return kwargs unless klass.const_defined?('ATTRIBUTES_MAPPING')

    kwargs.deep_transform_keys do |key|
      klass::ATTRIBUTES_MAPPING.values.include?(key.to_sym) ? klass::ATTRIBUTES_MAPPING.key(key.to_sym) : key
    end
  end

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
  #   "data": [
  #      ...
  #   ],
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

  # Invalidate cache when reaching the end of the current list and paginating over to the next set of results. Also enforce a `limit` parameter to the API
  # calls when supplied.
  def index_response
    kwargs.merge!(index_request_limit) unless @limit.infinite?

    @_index_response ||= begin
      ActiveAd.logger.info("Calling index_request with kwargs: #{kwargs}")
      klass.index_request(**kwargs)
    end
  end

  # TODO: Maybe move the different strategies into their own modules.

  def index_response_error
    case strategy
    when :cursor
      index_response.body['error']
    when :offset
      # index_response.body['error']
    end
  end

  def index_response_data(index)
    case strategy
    when :cursor
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
      # { offset: index_response.body.dig('paging', 'page').to_i * @limit }
    end
  end

  def index_request_limit
    case strategy
    when :cursor
      { limit: @limit }
    when :offset
      # { offset: @limit }
    end
  end
end