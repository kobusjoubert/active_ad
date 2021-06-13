class ActiveAd::Facebook::Client < ActiveAd::ClientInterface
  attr_accessor :client_id, :client_secret, :short_lived_access_token

  validates_presence_of :client_id, :client_secret

  def initialize(**kwargs)
    super
    @api_version = '11.0'
  end

  def login_request
    ActiveAd.connection.get("https://graph.facebook.com/v#{api_version}/oauth/access_token", {
      grant_type: 'fb_exchange_token',
      client_id: client_id,
      client_secret: client_secret,
      fb_exchange_token: short_lived_access_token
    })
  end

  private

  def set_access_token
    raise ActiveAd::LoginError, response.body['error'] unless response.success?
    @access_token = response.body['access_token']
  end
end
