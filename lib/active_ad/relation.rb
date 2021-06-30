class ActiveAd::Relation
  # The Enumerable mixin provides collection classes with several traversal and searching methods, and with the ability to sort. The class must provide a
  # method each, which yields successive members of the collection. If #max, min, or sort is used, the objects in the collection must also implement a
  # meaningful <=> operator, as these methods rely on an ordering between members of the collection.
  include Enumerable

  attr_reader :klass, :kwargs, :index

  def initialize(klass, **kwargs)
    @klass = klass
    @kwargs = kwargs
    @index ||= 0
    # @client = klass.client
    # @cursor
    # @before
    # @after
    # model_type = klass.to_s.split('::').last.underscore.to_sym # :account, :campaign, :ad_group, :ad
  end

  # === Data
  #
  # {
  #   "data": [
  #      ... Endpoint data is here
  #   ],
  #   "paging": {
  #     "cursors": {
  #       "after": "MTAxNTExOTQ1MjAwNzI5NDE=",
  #       "before": "NDMyNzQyODI3OTQw"
  #     }
  #   }
  # }
  #
  # === Error
  #
  # {
  #   "error": {
  #     "message": "(#100) The After Cursor specified exceeds the max limit supported by this endpoint",
  #     "type": "OAuthException",
  #     "code": 100
  #   }
  # }
  #
  # Returns an Enumerator.
  def each
    return to_enum(:each) unless block_given?

    loop do
      p "=== index: #{index}"

      raise index_response.body['error'] unless index_response.success?

      attributes = index_response.body['data'][index]

      if attributes
        object = klass.new(**attributes)
        yield object
      else
        @index = 0
        after = index_response.body.dig('paging', 'cursors', 'after')
        break unless after

        @_index_response = klass.index_request(after: after, **kwargs)
      end

      @index += 1
    end
  end

  # TODO: Implement some sort of count_request method.
  def count
    super
  end

  # Invalidate cache when reaching end of list and paginating over to the next set of results.
  def index_response
    @_index_response ||= klass.index_request(**kwargs)
  end
end
