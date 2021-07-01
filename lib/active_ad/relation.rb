class ActiveAd::Relation
  # The Enumerable mixin provides collection classes with several traversal and searching methods, and with the ability to sort. The class must provide a
  # method each, which yields successive members of the collection. If #max, min, or sort is used, the objects in the collection must also implement a
  # meaningful <=> operator, as these methods rely on an ordering between members of the collection.
  include Enumerable

  attr_reader :klass, :kwargs, :strategy

  # Platforms using this approach: Facebook.
  #
  # This class uses the `limit` and `after` query parameters.
  #
  # === Example
  #
  #   https://somewhere.com/resources?limit=10&after=a1b2c3
  def initialize(klass, **kwargs)
    @klass = klass
    @kwargs = kwargs
    @limit = Float::INFINITY
    @strategy = klass.client.pagination_type # :offset, :cursor, :relay_cursor
    # model_type = klass.to_s.split('::').last.underscore.to_sym # :account, :campaign, :ad_group, :ad
  end

  # Returns an Enumerator.
  def each
    return to_enum(:each) unless block_given?

    index = 0
    total = 0

    loop do
      p "=== index: #{index}"
      break if total >= @limit

      raise index_response_error unless index_response.success?

      attributes = index_response_data(index)

      if attributes
        object = klass.new(**attributes)
        yield object
      else
        index = 0
        offset = index_response_offset
        break if offset.values.last.blank?

        @_index_response = klass.index_request(**kwargs.merge(offset))
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

  # Invalidate cache when reaching the end of the current list and paginating over to the next set of results. Also enforce a `limit` parameter to the API
  # calls when supplied.
  def index_response
    kwargs.merge!(index_request_limit) unless @limit.infinite?
    @_index_response ||= klass.index_request(**kwargs)
  end

  private

  # Cursor based pagination.
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
