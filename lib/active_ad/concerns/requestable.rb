module ActiveAd::Requestable
  include ActiveSupport::Concern

  REQUEST_METHODS = %i[get head delete trace post put patch].freeze

  # Expect a hash with the first key being one of `REQUEST_METHODS`.
  #
  #   { get: 'http://somewhere.com' }
  #   { get: 'http://somewhere.com', params: {} }
  #   { post: 'http://somewhere.com', headers: {}, params: {}, body: {} }
  def request(kwargs)
    options = kwargs.deep_symbolize_keys
    request_method = options.keys[0]

    unless REQUEST_METHODS.include?(request_method)
      raise ArgumentError, "First key in the arguments hash was #{request_method}, must be one of #{REQUEST_METHODS.join(', ')}"
    end

    url = options[request_method]

    ActiveAd.logger.info("Requesting #{request_method.upcase} #{url} with options: #{options}")

    ActiveAd.connection.send(request_method, url) do |req|
      req.headers = options[:headers] if options[:headers]
      req.params  = options[:params] if options[:params]
      req.body    = options[:body].to_json if options[:body]
    end
  end
end
