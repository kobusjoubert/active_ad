class ActiveAd::Facebook::Business < ActiveAd::Base
  # Identification attributes.
  alias_method :business_id, :id

  # Titles and descriptions attributes.
  attribute :name, :string

  # Other attributes.
  attribute :status, :string

  # validates_presence_of some_attribute

  # before_save :do_something
  # after_destroy :do_something
end
