class ActiveAd::Facebook::Campaign < ActiveAd::Campaign
  attr_accessor :fields

  # Attributes needed for creating and updating.
  attribute :bid_strategy, :string
  attribute :objective, :string, default: 'LINK_CLICKS'
  attribute :special_ad_categories, array: true, default: []
  attribute :status, :string, default: 'PAUSED'

  # TODO: Maybe use a class method that needs to be implemented on child objects, instead of using a constant?
  ATTRIBUTES_MAPPING = {
    effective_status: :status
  }

  READ_FIELDS = %w[
    ad_strategy_id adlabels bid_strategy budget_remaining buying_type can_use_spend_cap configured_status created_time daily_budget effective_status issues_info
    last_budget_toggling_time lifetime_budget name objective pacing_type promoted_object source_campaign source_campaign_id special_ad_categories
    special_ad_category special_ad_category_country spend_cap start_time status stop_time updated_time
  ]

  validates_presence_of :name, :status, :objective, on: :create
  validates_presence_of :special_ad_categories, allow_blank: true, on: :create

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
      fields: (fields || READ_FIELDS).join(',')
    })
  end

  # TODO: Finish this method.
  def create_request
    p "=== Response from CREATE request create_request_attributes: #{create_request_attributes}"

    ActiveAd.connection.post("https://graph.facebook.com/v#{api_version}/act_#{account_id}/campaigns",
      create_request_attributes.merge(access_token: access_token)
    )
  end

  def update_request
    p "=== Response from UPDATE request update_request_attributes: #{update_request_attributes}"

    ActiveAd.connection.post("https://graph.facebook.com/v#{api_version}/#{campaign_id}",
      update_request_attributes.merge(access_token: access_token)
    )
  end

  def delete_request
    p "=== Response from DELETE request campaign_id: #{campaign_id}"

    ActiveAd.connection.delete("https://graph.facebook.com/v#{api_version}/#{campaign_id}", {
      access_token: access_token
    })
  end
end
