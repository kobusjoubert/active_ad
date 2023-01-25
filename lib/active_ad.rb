require 'active_support'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/object/json'
require 'active_support/environment_inquirer'
require 'active_support/parameter_filter'
require 'active_support/configurable'
require 'active_model'
require 'faraday'
require 'faraday/retry'
require 'faraday/logging/color_formatter'
require 'zeitwerk'

Zeitwerk::Loader.for_gem.tap do |loader|
  loader.push_dir("#{__dir__}/active_ad/concerns", namespace: ActiveAd)
  loader.push_dir("#{__dir__}/active_ad/clients", namespace: ActiveAd)
  loader.collapse("#{__dir__}/active_ad/clients/*/concerns")
  loader.push_dir("#{__dir__}/active_ad/validators")
  loader.ignore("#{__dir__}/error.rb")
  loader.enable_reloading
end.setup

require_relative 'active_ad/error'

ActiveModel::Type.register(:enum, ActiveAd::Type::Enum)

module ActiveAd
  include ActiveSupport::Configurable

  config_accessor :raise_relational_errors, instance_accessor: false, default: true
  config_accessor :log_level, instance_accessor: false, default: :debug
  config_accessor :log_headers, instance_accessor: false, default: true
  config_accessor :log_bodies, instance_accessor: false, default: true

  class << self
    # Returns the current ActiveAd environment. Set to `development` only when requested.
    #
    #   ActiveAd.env # => 'development'
    #   ActiveAd.env.development? # => true
    #   ActiveAd.env.production? # => false
    def env
      @_env ||= ActiveSupport::EnvironmentInquirer.new(
        ENV['ACTIVE_AD_ENV'].presence || ''
      )
    end

    def connection
      @_connection ||= begin
        Faraday.new do |conn|
          conn.request :json # Encode req bodies as JSON
          conn.request :retry # Retry transient failures
          # conn.response :follow_redirects # Follow redirects
          conn.response :json # Decode response bodies as JSON
          conn.response :logger, logger, **logger_options do |logger|
            logger.filter(/(_secret|_token)=([^\&]+)/i, '\1=[FILTERED]')
            logger.filter(/(_secret:|_token:).*"(.+)."/i, '\1 [FILTERED]')
          end
          conn.adapter Faraday.default_adapter
        end
      end
    end

    def parameter_filter
      @_parameter_filter ||= ActiveSupport::ParameterFilter.new([/_secret/i, /_token/i], mask: '[FILTERED]')
    end

    def logger
      @_logger ||= ActiveSupport::Logger.new($stdout, level: "Logger::#{ActiveAd.config.log_level.to_s.upcase}".constantize)
    end

    def logger=(logger)
      @_logger = logger
    end

    private

    def logger_options
      {
        headers:   ActiveAd.config.log_headers,
        bodies:    ActiveAd.config.log_bodies,
        errors:    false, # ActiveAd raises its own errors.
        formatter: Faraday::Logging::ColorFormatter, prefix: { request: 'ActiveAd', response: 'ActiveAd', indent: 2 }
      }
    end
  end
end

require 'debug' if ActiveAd.env.development?

Zeitwerk::Loader.for_gem.tap do |loader|
  if ActiveAd.env.development?
    require 'listen'
    Listen.to('lib') { loader.reload }.start
    loader.log! if ActiveAd.config.log_level == :debug
    loader.eager_load # Optional, useful to test all files while developing.
  end
end
