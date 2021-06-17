class ActiveAd::Campaign < ActiveAd::Base
  attr_accessor :account, :campaign_id, :name

  delegate :platform, :api_version, :access_token, to: :account

  validates_presence_of :account

  # before_save :do_something
  # after_destroy :do_something

  alias_method :id, :campaign_id
end
