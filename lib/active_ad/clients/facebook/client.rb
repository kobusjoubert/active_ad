class ActiveAd::Facebook::Client < ActiveAd::ClientInterface
  attr_reader :username, :access_token

  def initialize(options = {})
    @username = options[:username]
    @access_token = options[:access_token]
  end

  def login
    'logging in...'
  end
end
