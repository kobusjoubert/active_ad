class ActiveAd::Facebook::Client < ActiveAd::Client
  include ActiveAd::Facebook::Requestable

  api_version '15.0'
  base_url "https://graph.facebook.com/v#{api_version}"
  pagination_type :cursor

  attribute :app_id, :string, default: ActiveAd::Facebook.app_id
  attribute :app_secret, :string, default: ActiveAd::Facebook.app_secret
  attribute :short_lived_access_token

  # Useful permissions required on the short_lived_access_token.
  #
  #   - public_profile
  #   - email
  #   - pages_show_list
  #   - pages_manage_ads
  #   - read_insights
  #   - ads_management
  #   - business_management
  #   - leads_retrieval
  def login_request
    {
      get: "#{base_url}/oauth/access_token",
      params: {
        client_id: app_id,
        client_secret: app_secret,
        grant_type: 'fb_exchange_token',
        fb_exchange_token: short_lived_access_token
      }
    }
  end

  def refresh_token_request
    {
      get: "#{base_url}/oauth/access_token",
      params: {
        client_id: app_id,
        client_secret: app_secret,
        grant_type: 'fb_exchange_token',
        fb_exchange_token: access_token
      }
    }
  end

  private

  def set_access_token
    self.access_token = response.body['access_token']
  end
end
