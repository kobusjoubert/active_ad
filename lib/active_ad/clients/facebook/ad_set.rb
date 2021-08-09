class ActiveAd::Facebook::AdSet < ActiveAd::Base
  # Requesting the following fields causes status `400` error with messages.
  #
  #   'contextual_bundling_spec' => "(#3) Ad Account must be on allowlist"
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
  BID_STRATEGIES = %w[LOWEST_COST_WITHOUT_CAP LOWEST_COST_WITH_BID_CAP COST_CAP].freeze
  BILLING_EVENTS = %w[APP_INSTALLS CLICKS IMPRESSIONS LINK_CLICKS NONE OFFER_CLAIMS PAGE_LIKES POST_ENGAGEMENT THRUPLAY PURCHASE LISTING_INTERACTION].freeze
  DESTINATION_TYPES = %w[UNDEFINED WEBSITE APP MESSENGER APPLINKS_AUTOMATIC FACEBOOK].freeze
  MULTI_OPTIMIZATION_GOAL_WEIGHTS = %w[UNDEFINED BALANCED PREFER_INSTALL PREFER_EVENT].freeze
  OPTIMIZATION_GOALS = %w[
    NONE APP_INSTALLS BRAND_AWARENESS AD_RECALL_LIFT CLICKS ENGAGED_USERS EVENT_RESPONSES IMPRESSIONS LEAD_GENERATION QUALITY_LEAD LINK_CLICKS OFFER_CLAIMS
    OFFSITE_CONVERSIONS PAGE_ENGAGEMENT PAGE_LIKES POST_ENGAGEMENT QUALITY_CALL REACH SOCIAL_IMPRESSIONS APP_DOWNLOADS TWO_SECOND_CONTINUOUS_VIDEO_VIEWS
    LANDING_PAGE_VIEWS VISIT_INSTAGRAM_PROFILE VALUE THRUPLAY REPLIES DERIVED_EVENTS
  ].freeze
  OPTIMIZATION_SUB_EVENTS = %w[
    NONE VIDEO_SOUND_ON TRIP_CONSIDERATION TRAVEL_INTENT TRAVEL_INTENT_NO_DESTINATION_INTENT TRAVEL_INTENT_BUCKET_01 TRAVEL_INTENT_BUCKET_02
    TRAVEL_INTENT_BUCKET_03 TRAVEL_INTENT_BUCKET_04 TRAVEL_INTENT_BUCKET_05
  ].freeze
  STATUS = %w[ACTIVE PAUSED DELETED ARCHIVED].freeze
  TUNE_FOR_CATEGORIES = %w[NONE EMPLOYMENT HOUSING CREDIT ISSUES_ELECTIONS_POLITICS].freeze

  belongs_to :account
  belongs_to :campaign
  has_many :ads

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
  attribute :id, :big_integer
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
  attribute :campaign_spec
  attribute :configured_status, :string
  attribute :contextual_bundling_spec
  attribute :created_at, :datetime
  attribute :creative_sequence, array: true
  attribute :daily_budget, :big_integer
  attribute :daily_imps, :big_integer
  attribute :daily_min_spend_target, :big_integer
  attribute :daily_spend_cap, :big_integer
  attribute :destination_type, :string
  attribute :effective_status, :string
  attribute :execution_options, array: true
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
  attribute :rf_prediction_id, :big_integer
  attribute :source_adset
  attribute :source_adset_id, :big_integer
  attribute :start_at, :datetime
  attribute :status, :string # default: 'PAUSED'
  attribute :targeting
  attribute :time_based_ad_rotation_id_blocks, array: true
  attribute :time_based_ad_rotation_intervals, array: true
  attribute :time_start, :datetime
  attribute :time_stop, :datetime
  attribute :tune_for_category, :string
  attribute :updated_at, :datetime
  attribute :use_new_app_click, :boolean

  # Use validations which will overwrite the parent class implementations.
  #
  # validates_length_of :title, maximum: 24
  # validates :titles, titles_length: { maximums: [24, 50] }
  validates_presence_of :name, :status, on: :create

  validates_inclusion_of :bid_strategy, in: BID_STRATEGIES, allow_blank: true, message: validates_inclusion_of_message(BID_STRATEGIES)
  validates_inclusion_of :billing_event, in: BILLING_EVENTS, allow_blank: true, message: validates_inclusion_of_message(BILLING_EVENTS)
  validates_inclusion_of :destination_type, in: DESTINATION_TYPES, allow_blank: true, message: validates_inclusion_of_message(DESTINATION_TYPES)
  validates_inclusion_of :multi_optimization_goal_weight, in: MULTI_OPTIMIZATION_GOAL_WEIGHTS,
                                                          allow_blank: true,
                                                          message: validates_inclusion_of_message(MULTI_OPTIMIZATION_GOAL_WEIGHTS)
  validates_inclusion_of :optimization_goal, in: OPTIMIZATION_GOALS, allow_blank: true, message: validates_inclusion_of_message(OPTIMIZATION_GOALS)
  validates_inclusion_of :optimization_sub_event, in: OPTIMIZATION_SUB_EVENTS,
                                                  allow_blank: true,
                                                  message: validates_inclusion_of_message(OPTIMIZATION_SUB_EVENTS)
  validates_inclusion_of :status, in: STATUS, allow_blank: true, message: validates_inclusion_of_message(STATUS)
  validates_inclusion_of :tune_for_category, in: TUNE_FOR_CATEGORIES, allow_blank: true, message: validates_inclusion_of_message(TUNE_FOR_CATEGORIES)

  validates_numericality_of :account_id, :campaign_id, :bid_amount, :daily_budget, :daily_imps, :daily_min_spend_target, :daily_spend_cap, :lifetime_budget,
                            :lifetime_imps, :lifetime_min_spend_target, :lifetime_spend_cap, :rf_prediction_id, allow_nil: true, greater_than: 0

  # Use callbacks to execute code that should happen before or after `create`, `update`, `save` or `destroy`.
  #
  # before_save :do_something
  # after_destroy :do_something

  class << self
    def index_request(**kwargs)
      params = kwargs.dup
      id, id_key = index_request_id_and_key(params)

      id = "act_#{id}" if id_key == :account_id
      fields = params.delete(:fields) || READ_FIELDS

      {
        get: "#{client.base_url}/#{id}/adsets",
        params: params.merge(access_token: client.access_token, fields: fields.join(','))
      }
    end
  end

  def read_request(**kwargs)
    params = kwargs.dup
    fields = ((params.delete(:fields) || READ_FIELDS) + relational_attributes).uniq

    {
      get: "#{client.base_url}/#{id}",
      params: params.merge(access_token: client.access_token, fields: fields.join(','))
    }
  end

  def create_request
    {
      post: "#{client.base_url}/act_#{account_id}/adsets",
      body: create_request_attributes.merge(access_token: client.access_token)
    }
  end

  def update_request
    {
      post: "#{client.base_url}/#{id}",
      body: update_request_attributes.merge(access_token: client.access_token)
    }
  end

  def delete_request
    {
      delete: "#{client.base_url}/#{id}",
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
    %i[account_id campaign_id]
  end
end
