require 'active_support'
require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/object/json'
require 'active_support/environment_inquirer'
require 'active_model'
require 'faraday'
require 'faraday_middleware'

module ActiveAd
  class << self
    # Returns the current ActiveAd environment. Set to `development` only when requested.
    #
    #   ActiveAd.env # => 'development'
    #   ActiveAd.env.development? # => true
    #   ActiveAd.env.production? # => false
    def env
      @_env ||= ActiveSupport::EnvironmentInquirer.new(
        ENV['ACTIVE_AD_ENV'].presence || ENV['RAILS_ENV'].presence || ENV['RACK_ENV'].presence || ''
      )
    end

    def connection
      @_connection ||= begin
        Faraday.new do |conn|
          conn.request :json # Encode req bodies as JSON
          conn.request :retry # Retry transient failures
          # conn.response :follow_redirects # Follow redirects
          conn.response :json # Decode response bodies as JSON
          conn.adapter Faraday.default_adapter
        end
      end
    end

    def logger
      @_logger ||= Logger.new($stdout)
    end
  end
end

ActiveAd.logger.level = ActiveAd.env.development? ? Logger::DEBUG : Logger::INFO

require 'zeitwerk'

loader = Zeitwerk::Loader.for_gem
loader.push_dir("#{__dir__}/active_ad/concerns", namespace: ActiveAd)
loader.push_dir("#{__dir__}/active_ad/clients", namespace: ActiveAd)
loader.push_dir("#{__dir__}/active_ad/validators")

if ActiveAd.env.development?
  loader.log!
  loader.enable_reloading
end

loader.setup

if ActiveAd.env.development?
  require 'byebug'
  require 'listen'
  Listen.to('lib') { loader.reload }.start
end

ActiveModel::Type.register(:enum, ActiveAd::Type::Enum)

# The documentation says to put your code here, but some have reported problems in production, which is why it's at the top for now.
# https://rewind.com/blog/zeitwerk-autoloader-rails-app/
# module ActiveAd; end

loader.eager_load # Optional, useful to test all files while developing.
