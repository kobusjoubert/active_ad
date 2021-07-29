class ActiveAd::Facebook::AdSet < ActiveAd::Base
  # Requesting the following fields causes status `400` error with messages.
  #
  #   'contextual_bundling_spec' => "(#3) Ad Account must be on allowlist".
  #
  # Attributes that clashes with the relational methods.
  #
  #   'campaign'
  READ_FIELDS = %i[
    id account_id adlabels adset_schedule asset_feed_id attribution_spec bid_adjustments bid_amount bid_constraints bid_info bid_strategy billing_event
    budget_remaining campaign_id configured_status created_time creative_sequence daily_budget daily_min_spend_target daily_spend_cap destination_type
    effective_status end_time frequency_control_specs instagram_actor_id is_dynamic_creative issues_info learning_stage_info lifetime_budget lifetime_imps
    lifetime_min_spend_target lifetime_spend_cap multi_optimization_goal_weight name optimization_goal optimization_sub_event pacing_type promoted_object
    recommendations recurring_budget_semantics review_feedback rf_prediction_id source_adset source_adset_id start_time status targeting
    time_based_ad_rotation_id_blocks time_based_ad_rotation_intervals updated_time use_new_app_click
  ].freeze

  belongs_to :campaign
  has_many :ads

  attribute :id, :big_integer

  # Use aliases to map external API attributes to the ActiveAd object attributes. We especially want to make sure identitfication attributes end with an '_id'
  # suffix. For example 'platform_attribute' should be aliased as 'platform_attribute_id'. This way when we call 'object.platform_attribute_id' we know we're
  # getting back an ID instead of an object.
  #
  # alias_attribute :platform_attribute, :active_ad_attribute
  alias_attribute :adlabels, :ad_labels
  alias_attribute :created_time, :created_at
  alias_attribute :end_time, :end_at
  alias_attribute :start_time, :start_at
  alias_attribute :updated_time, :updated_at

  # ActiveAd object attributes.
  attribute :account_id, :big_integer
  attribute :ad_labels, array: true
  attribute :adset_schedule, array: true
  attribute :asset_feed_id, :big_integer
  attribute :attribution_spec, array: true
  attribute :bid_adjustments
  attribute :bid_amount, :integer
  attribute :bid_constraints
  attribute :bid_info
  attribute :bid_strategy, :string
  attribute :billing_event, :string # default: 'LINK_CLICKS'
  attribute :budget_remaining, :big_integer
  # attribute :campaign # Clashes with the `belongs_to :campaign` relationship.
  attribute :campaign_id, :big_integer
  attribute :configured_status, :string
  attribute :contextual_bundling_spec
  attribute :created_at, :datetime
  attribute :creative_sequence, array: true
  attribute :daily_budget, :big_integer
  attribute :daily_min_spend_target, :big_integer
  attribute :daily_spend_cap, :big_integer
  attribute :destination_type, :string
  attribute :effective_status, :string
  attribute :end_at, :datetime
  attribute :frequency_control_specs, array: true
  attribute :instagram_actor_id, :big_integer
  attribute :is_dynamic_creative, :boolean
  attribute :issues_info, array: true
  attribute :learning_stage_info
  attribute :lifetime_budget, :big_integer
  attribute :lifetime_imps, :integer
  attribute :lifetime_min_spend_target, :big_integer
  attribute :lifetime_spend_cap, :big_integer
  attribute :multi_optimization_goal_weight, :string
  attribute :name, :string
  attribute :optimization_goal, :string
  attribute :optimization_sub_event, :string
  attribute :pacing_type, array: true
  attribute :promoted_object
  attribute :recommendations, array: true
  attribute :recurring_budget_semantics, :boolean
  attribute :review_feedback, :string
  attribute :rf_prediction_id, :big_integer # TODO: The Facebook type is `id`?
  attribute :source_adset
  attribute :source_adset_id, :big_integer
  attribute :start_at, :datetime
  attribute :status, :string # default: 'PAUSED'
  attribute :targeting
  attribute :time_based_ad_rotation_id_blocks, array: true
  attribute :time_based_ad_rotation_intervals, array: true
  attribute :updated_at, :datetime
  attribute :use_new_app_click, :boolean

  # Use validations which will overwrite the parent class implementations.
  #
  # validates_length_of :title, maximum: 24
  # validates :titles, titles_length: { maximums: [24, 50] }
  validates_presence_of :name, :status, on: :create

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
    params = kwargs.dup
    fields = ((params.delete(:fields) || READ_FIELDS) + relational_attributes).uniq

    {
      get: "https://graph.facebook.com/v#{client.api_version}/#{id}",
      params: params.merge(access_token: client.access_token, fields: fields.join(','))
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
      post: "https://graph.facebook.com/v#{client.api_version}/#{id}",
      body: update_request_attributes.merge(access_token: client.access_token)
    }
  end

  def delete_request
    {
      delete: "https://graph.facebook.com/v#{client.api_version}/#{id}",
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

  # List all the relational attributes required for `belongs_to` to know which parent to request.
  def relational_attributes
    [:campaign_id]
  end
end
