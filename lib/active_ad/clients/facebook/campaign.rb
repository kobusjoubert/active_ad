class ActiveAd::Facebook::Campaign < ActiveAd::CampaignInterface
  # Must be able to use your own validations, taking precedence over what the interface supplies.
  # validates_length_of :title, maximum: 24
  # validates :titles, titles_length: { maximums: [24, 50] }

  # Must be able to use your own callbacks.
  # before_save :do_something
  # after_destroy :do_something

  def create_request
    "Response from CREATE request"
  end

  def update_request
    "Response from UPDATE request"
  end

  def delete_request
    "Response from DELETE request"
  end
end
