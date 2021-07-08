class ActiveAd::Facebook::AdGroup < ActiveAd::AdGroup
  # Attributes needed for creating and updating.
  attribute :account_id, :string
  attribute :bid_amount, :integer
  attribute :billing_event, :string, default: 'LINK_CLICKS'
  attribute :daily_budget, :integer
  attribute :status, :string, default: 'PAUSED'
  attribute :targeting

  # Both `effective_status` and `status` are supplied by Facebook, so mapping `effective_status: :status` will cause conflicts.
  ATTRIBUTES_MAPPING = {}.freeze

  READ_FIELDS = %w[
    adlabels adset_schedule attribution_spec bid_adjustments bid_amount bid_constraints bid_info bid_strategy billing_event budget_remaining campaign_id
    configured_status created_time daily_budget daily_min_spend_target daily_spend_cap destination_type effective_status end_time frequency_control_specs
    is_dynamic_creative issues_info learning_stage_info lifetime_budget lifetime_imps lifetime_min_spend_target lifetime_spend_cap
    multi_optimization_goal_weight name optimization_goal optimization_sub_event pacing_type promoted_object recommendations recurring_budget_semantics
    review_feedback rf_prediction_id source_adset_id start_time status targeting time_based_ad_rotation_id_blocks time_based_ad_rotation_intervals updated_time
    use_new_app_click
  ].freeze

  validates_presence_of :name, :status, on: :create

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
      params = kwargs.dup
      raise ArgumentError, "Expected :campaign_id to be present, got #{params}" unless (campaign_id = params.delete(:campaign_id))

      fields = params.delete(:fields) || READ_FIELDS

      {
        get: "https://graph.facebook.com/v#{client.api_version}/#{campaign_id}/adsets",
        params: params.merge(access_token: client.access_token, fields: fields.join(','))
      }
    end
  end

  def read_request(**kwargs)
    fields = kwargs[:fields] || READ_FIELDS

    {
      get: "https://graph.facebook.com/v#{client.api_version}/#{ad_group_id}",
      params: { access_token: client.access_token, fields: fields.join(',') }
    }
  end

  def create_request
    {
      post: "https://graph.facebook.com/v#{client.api_version}/act_#{account_id}/adsets",
      body: create_request_attributes.merge(access_token: client.access_token)
    }
  end

  def update_request
    {
      post: "https://graph.facebook.com/v#{client.api_version}/#{ad_group_id}",
      body: update_request_attributes.merge(access_token: client.access_token)
    }
  end

  def delete_request
    {
      delete: "https://graph.facebook.com/v#{client.api_version}/#{ad_group_id}",
      params: { access_token: client.access_token }
    }
  end

  private

  def create_request_attributes
    super.except('account_id')
  end

  def create_response_id(response)
    response.body['id']
  end
end
