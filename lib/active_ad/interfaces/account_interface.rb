class ActiveAd::AccountInterface < ActiveAd::BaseInterface
  attr_accessor :client, :name

  validates_presence_of :client

  # before_save :do_something
  # after_destroy :do_something
end
