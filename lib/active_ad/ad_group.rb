class ActiveAd::AdGroup < ActiveAd::Base
  attr_accessor :campaign, :ad_group_id, :name

  delegate :platform, :api_version, :access_token, to: :campaign

  validates_presence_of :campaign

  # before_save :do_something
  # after_destroy :do_something

  alias_method :id, :ad_group_id
end
