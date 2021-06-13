class ActiveAd::AccountInterface < ActiveAd::BaseInterface
  attr_accessor :client, :name, :account_id

  delegate :api_version, :access_token, to: :client

  validates_presence_of :client

  # before_save :do_something
  # after_destroy :do_something
end
