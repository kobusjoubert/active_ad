class ActiveAd::Facebook::Campaign < ActiveAd::Campaign
  # Must be able to use your own validations, taking precedence over what the interface supplies.
  #
  # validates_length_of :title, maximum: 24
  # validates :titles, titles_length: { maximums: [24, 50] }

  # Must be able to use your own callbacks.
  #
  # before_save :do_something
  # after_destroy :do_something

  def read_request
    ActiveAd.connection.get("https://graph.facebook.com/v#{api_version}/#{campaign_id}", {
      access_token: access_token,
      fields: 'name'
    })
  end

  def create_request
    ActiveAd.connection.post("https://graph.facebook.com/v#{api_version}/act_#{account.account_id}/campaigns", {
      access_token: access_token,
      name: 'Test Campaign From Gem',
      objective: 'LINK_CLICKS',
      status: 'PAUSED',
      special_ad_categories: '[]'
    })
  end

  def update_request
    "Response from UPDATE request"
  end

  def delete_request
    "Response from DELETE request"
  end
end
