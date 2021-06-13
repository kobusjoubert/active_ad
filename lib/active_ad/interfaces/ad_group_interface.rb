class ActiveAd::AdGroupInterface < ActiveAd::BaseInterface
  attr_accessor :campaign, :name

  delegate :api_version, :access_token, to: :campaign

  validates_presence_of :campaign

  # before_save :do_something
  # after_destroy :do_something
end
