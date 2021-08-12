# === Configuration
#
# Set an access token and secrets which will be used in all requests to this specific platform.
#
#   ActiveAd::Facebook.configure do |config|
#     config.client = ActiveAd::Facebook::Client.new(access_token: 'd4e5f6', client_id: '123', client_secret: 'a1b2c3')
#   end
class ActiveAd::Configuration
  include ActiveSupport::Configurable

  config_accessor :client, instance_reader: false
end
