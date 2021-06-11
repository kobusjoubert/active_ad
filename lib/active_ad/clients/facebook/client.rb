class ActiveAd::Facebook::Client < ActiveAd::ClientInterface
  attr_accessor :short_lived_access_token, :client_id, :client_secret
  attr_reader :api_version

  validates_presence_of :client_id, :client_secret

  # after_login :set_access_token

  def initialize(**kwargs)
    super
    @api_version = '11.0'
  end

  def login_request
    Faraday.get("https://graph.facebook.com/v#{api_version}/oauth/access_token", {
      grant_type: 'fb_exchange_token',
      client_id: client_id,
      client_secret: client_secret,
      fb_exchange_token: short_lived_access_token
    })
  end

  private

  def set_access_token
    raise ActiveAd::LoginError, response[:error] unless request.success?
    @access_token = response[:access_token]
  end
end
