class ActiveAd::Account < ActiveAd::Base
  attr_accessor :client, :account_id, :name

  delegate :platform, :api_version, :access_token, to: :client

  validates_presence_of :client

  # before_save :do_something
  # after_destroy :do_something

  alias_method :id, :account_id
end
