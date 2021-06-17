class ActiveAd::Facebook::Client < ActiveAd::Client
  attr_accessor :client_id, :client_secret, :short_lived_access_token

  validates_presence_of :client_id, :client_secret

  def initialize(**kwargs)
    super
    @api_version = '11.0'
  end

  # Permissions required on the short_lived_access_token: email, ads_management, business_management, leads_retrieval
  def login_request
    ActiveAd.connection.get("https://graph.facebook.com/v#{api_version}/oauth/access_token", {
      client_id: client_id,
      client_secret: client_secret,
      grant_type: 'fb_exchange_token',
      fb_exchange_token: short_lived_access_token
    })
  end

  private

  def set_access_token
    raise ActiveAd::LoginError, response.body['error'] unless response.success?
    @access_token = response.body['access_token']
  end
end
