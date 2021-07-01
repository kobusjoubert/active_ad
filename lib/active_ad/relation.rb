class ActiveAd::Relation
  # The Enumerable mixin provides collection classes with several traversal and searching methods, and with the ability to sort. The class must provide a
  # method each, which yields successive members of the collection. If #max, min, or sort is used, the objects in the collection must also implement a
  # meaningful <=> operator, as these methods rely on an ordering between members of the collection.
  include Enumerable

  attr_reader :klass, :kwargs

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
    # model_type = klass.to_s.split('::').last.underscore.to_sym # :account, :campaign, :ad_group, :ad
  end

  # === Data
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
  #
  # Returns an Enumerator.
  def each
    return to_enum(:each) unless block_given?

    index = 0
    total = 0

    loop do
      p "=== index: #{index}"
      break if total >= @limit

      raise index_response.body['error'] unless index_response.success?

      attributes = index_response.body['data'][index]

      if attributes
        object = klass.new(**attributes)
        yield object
      else
        index = 0
        after = index_response.body.dig('paging', 'cursors', 'after')
        break unless after

        @_index_response = klass.index_request(after: after, **kwargs)
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
    kwargs[:limit] = @limit unless @limit.infinite?
    @_index_response ||= klass.index_request(**kwargs)
  end
end
