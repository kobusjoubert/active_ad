class ActiveAd::Facebook::Client < ActiveAd::Client
  api_version '13.0'
  base_url "https://graph.facebook.com/v#{api_version}"
  pagination_type :cursor

  attribute :client_id
  attribute :client_secret
  attribute :short_lived_access_token

  validates_presence_of :client_id, :client_secret

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
        client_id: client_id,
        client_secret: client_secret,
        grant_type: 'fb_exchange_token',
        fb_exchange_token: short_lived_access_token
      }
    }
  end

  def refresh_token_request
    {
      get: "#{base_url}/oauth/access_token",
      params: {
        client_id: client_id,
        client_secret: client_secret,
        grant_type: 'fb_exchange_token',
        fb_exchange_token: access_token
      }
    }
  end

  def user(**kwargs)
    "ActiveAd::#{platform_class}::User".constantize.find('me', **kwargs)
  end

  private

  def set_access_token
    self.access_token = response.body['access_token']
  end
end
