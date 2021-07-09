class ActiveAd::AdCreative < ActiveAd::Base
  # Attributes needed for creating and updating.
  attribute :id, :string
  attribute :name, :string
  attribute :ad_id, :string

  # validates_presence_of :some_attribute

  # before_save :do_something
  # after_destroy :do_something

  alias_method :ad_creative_id, :id
end
