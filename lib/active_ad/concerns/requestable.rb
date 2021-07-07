module ActiveAd::Requestable
  include ActiveSupport::Concern

  def request(kwargs)
    request_method = kwargs.keys[0] # :get, :head, :delete, :trace, :post, :put, :patch
    url = kwargs.delete(request_method)

    ActiveAd.connection.send(request_method, url) do |req|
      req.headers = kwargs[:headers] if kwargs[:headers]
      req.params  = kwargs[:params] if kwargs[:params]
      req.body    = kwargs[:body].to_json if kwargs[:body]
    end
  end
end
