module ActiveAd::Requestable
  include ActiveSupport::Concern

  REQUEST_METHODS = %i[get head delete trace post put patch]

  def request(kwargs)
    request_method = kwargs.keys[0]

    unless REQUEST_METHODS.include?(request_method)
      raise ArgumentError, "First key in the arguments hash was #{request_method}, must be one of #{REQUEST_METHODS.join(', ')}"
    end

    url = kwargs.delete(request_method)

    ActiveAd.logger.info("Sending #{request_method.upcase} request to #{url} with kwargs: #{kwargs}")

    ActiveAd.connection.send(request_method, url) do |req|
      req.headers = kwargs[:headers] if kwargs[:headers]
      req.params  = kwargs[:params] if kwargs[:params]
      req.body    = kwargs[:body].to_json if kwargs[:body]
    end
  end
end
