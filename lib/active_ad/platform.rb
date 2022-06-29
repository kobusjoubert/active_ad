# === Configuration
#
# Set an access token and secrets which will be used in all requests to this specific platform.
#
#   ActiveAd::Facebook.configure do |config|
#     config.app_id = '123'
#     config.app_secret = 'a1b2c3'
#   end
#
#   ActiveAd::Facebook.client # => #<ActiveAd::Facebook::Client:0x...>
class ActiveAd::Platform
  include ActiveSupport::Configurable

  config_accessor :app_id, instance_accessor: false
  config_accessor :app_secret, instance_accessor: false
end
