class ActiveAd::Facebook::Account < ActiveAd::Account
  # Must be able to use your own validations, taking precedence over what the interface supplies.
  # validates_length_of :title, maximum: 24
  # validates :titles, titles_length: { maximums: [24, 50] }

  # Must be able to use your own callbacks.
  # before_save :do_something
  # after_destroy :do_something

  def find_request
    ActiveAd.connection.get("https://graph.facebook.com/v#{api_version}/act_#{account_id}", {
      access_token: access_token
    })
  end

  def create_request
    "Response from CREATE request"
    find_request
  end

  def update_request
    "Response from UPDATE request"
  end

  def delete_request
    "Response from DELETE request"
  end
end
