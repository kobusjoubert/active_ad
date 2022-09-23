# When including into a class, the `@klass` attribute should be set if the class making the request cannot be determined with `self.class`. An example of this
# would be when calling `request` from a Relation class instead of an `Ad` or `Campaign` class for instance.
#
# Logging colors: [https://misc.flogisoft.com/bash/tip_colors_and_formatting]
module ActiveAd::Requestable
  extend ActiveSupport::Concern

  REQUEST_METHODS = %i[get head delete trace post put patch].freeze
  ANSI_COLORS = { red: "\e[31m", green: "\e[32m", yellow: "\e[33m", blue: "\e[34m", magenta: "\e[35m", cyan: "\e[36m", reset: "\e[0m" }.freeze

  # Expect a hash with the first key being one of `REQUEST_METHODS`.
  #
  #   { get: 'http://somewhere.com' }
  #   { get: 'http://somewhere.com', params: {} }
  #   { post: 'http://somewhere.com', headers: {}, params: {}, body: {} }
  def request(kwargs)
    klass = respond_to?(:klass) ? self.klass : self.class
    options = kwargs_for_request(klass, **kwargs).deep_symbolize_keys
    request_method = options.keys[0]

    unless REQUEST_METHODS.include?(request_method)
      raise ArgumentError, "first key in the arguments hash was #{request_method}, must be one of #{REQUEST_METHODS.join(', ')}"
    end

    url = options[request_method]

    ActiveAd.logger.info(
      "#{ANSI_COLORS[:blue]}  ActiveAd #{request_log_color(request_method)} #{request_method.upcase} #{url} with options: " \
      "#{ActiveAd.parameter_filter.filter(options)}#{ANSI_COLORS[:reset]}"
    )

    response = ActiveAd.connection.send(request_method, url) do |req|
      req.headers = options[:headers] if options[:headers]
      req.params  = options[:params] if options[:params]
      req.body    = options[:body].to_json if options[:body]
    end

    unless response.success?
      ActiveAd.logger.warn(
        "#{ANSI_COLORS[:yellow]}  ActiveAd  #{request_method.upcase} #{url} with options: #{ActiveAd.parameter_filter.filter(options)} failed with reason: " \
        "#{response.body}#{ANSI_COLORS[:reset]}"
      )

      errors.add(:base, :api, message: api_error_message(response))
    end

    response
  end

  private

  # Exchange attribute keys to map what the external API expects.
  #
  #   kwargs             => { name: "My Campaign", status: "PAUSED" }
  #   kwargs_for_request => { name: "My Campaign", platform_status: "PAUSED" }
  def kwargs_for_request(klass, **kwargs)
    kwargs.deep_transform_keys do |key|
      (klass.attribute_aliases.has_value?(key) ? klass.attribute_aliases.key(key) : key).to_sym
    end
  end

  # Exchange attribute keys to map what the internal API expects.
  #
  #   kwargs            => { name: "My Campaign", platform_status: "PAUSED" }
  #   kwargs_for_object => { name: "My Campaign", status: "PAUSED" }
  def kwargs_for_object(klass, **kwargs)
    kwargs.deep_transform_keys do |key|
      (klass.attribute_aliases[key] || key).to_sym
    end
  end

  def api_error_message(response)
    raise NotImplementedError, 'Subclasses must implement a api_error_message method'
  end

  def request_log_color(request_method)
    case request_method
    when :post
      ANSI_COLORS[:green]
    when :put, :patch
      ANSI_COLORS[:yellow]
    when :delete
      ANSI_COLORS[:red]
    else
      ANSI_COLORS[:blue]
    end
  end
end
