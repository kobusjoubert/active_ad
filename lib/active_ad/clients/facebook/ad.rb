class ActiveAd::Facebook::Ad < ActiveAd::Ad
  # Use validations which will overwrite the parent class implementations.
  #
  validates_length_of :title, maximum: 24
  # validates :titles, titles_length: { maximums: [24, 50] }

  # Use callbacks to execute code that should happen before or after `create`, `update`, `save` or `destroy`.
  #
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
