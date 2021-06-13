class ActiveAd::CampaignInterface < ActiveAd::BaseInterface
  attr_accessor :account, :name

  delegate :api_version, :access_token, to: :account

  validates_presence_of :account

  # before_save :do_something
  # after_destroy :do_something
end
