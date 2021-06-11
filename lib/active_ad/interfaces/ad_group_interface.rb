class ActiveAd::AdGroupInterface < ActiveAd::BaseInterface
  attr_accessor :campaign, :name

  validates_presence_of :campaign

  # before_save :do_something
  # after_destroy :do_something
end
