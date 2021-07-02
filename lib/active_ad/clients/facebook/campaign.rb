class ActiveAd::Facebook::Campaign < ActiveAd::Campaign
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

  # Use validations which will overwrite the parent class implementations.
  #
  # validates_length_of :title, maximum: 24
  # validates :titles, titles_length: { maximums: [24, 50] }

  # Use callbacks to execute code that should happen before or after `create`, `update`, `save` or `destroy`.
  #
  # before_save :do_something
  # after_destroy :do_something

  class << self
    def index_request(**kwargs)
      raise ArgumentError, "Expected to include an :account_id, got #{kwargs.inspect}" unless account_id = kwargs.delete(:account_id)

      fields = kwargs.delete(:fields) || READ_FIELDS

      ActiveAd.connection.get("https://graph.facebook.com/v#{client.api_version}/act_#{account_id}/campaigns",
        kwargs.merge(access_token: client.access_token, fields: fields.join(','))
      )
    end
  end

  # TODO: Maybe all of these should be class methods.
  def read_request(**kwargs)
    fields = kwargs[:fields] || READ_FIELDS

    ActiveAd.connection.get("https://graph.facebook.com/v#{client.api_version}/#{campaign_id}", {
      access_token: client.access_token, fields: fields.join(',')
    })
  end

  def create_request
    ActiveAd.connection.post("https://graph.facebook.com/v#{client.api_version}/act_#{account_id}/campaigns",
      create_request_attributes.merge(access_token: client.access_token)
    )
  end

  def update_request
    ActiveAd.connection.post("https://graph.facebook.com/v#{client.api_version}/#{campaign_id}",
      update_request_attributes.merge(access_token: client.access_token)
    )
  end

  def delete_request
    ActiveAd.connection.delete("https://graph.facebook.com/v#{client.api_version}/#{campaign_id}", {
      access_token: client.access_token
    })
  end

  def create_response_id(response)
    response.body['id']
  end
end
