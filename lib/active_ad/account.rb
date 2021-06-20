class ActiveAd::Account < ActiveAd::Base
  # Attributes needed for creating and updating.
  attribute :id, :string
  attribute :name, :string
  attribute :status, :string

  # validates_presence_of :some_attribute

  # before_save :do_something
  # after_destroy :do_something

  alias_method :account_id, :id
end
