require 'active_support'
require 'active_support/core_ext/string/inflections'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/object/blank'
require 'active_support/environment_inquirer'
require 'active_model'
require 'active_model/callbacks'
require 'active_model/validations'

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
  end
end

require 'zeitwerk'

loader = Zeitwerk::Loader.for_gem
loader.push_dir("#{__dir__}/active_ad/clients", namespace: ActiveAd)
loader.push_dir("#{__dir__}/active_ad/interfaces", namespace: ActiveAd)
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

# The documentation says to put your code here, but some have reported problems in production, which is why it's at the top for now.
# https://rewind.com/blog/zeitwerk-autoloader-rails-app/
# module ActiveAd; end

loader.eager_load # Optional, useful to test all files while developing.
