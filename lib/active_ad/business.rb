class ActiveAd::Business < ActiveAd::Base
  attr_accessor :client, :business_id, :name

  delegate :platform, :api_version, :access_token, to: :client

  validates_presence_of :client

  # before_save :do_something
  # after_destroy :do_something

  alias_method :id, :business_id
end
