class ActiveAd::Facebook::Campaign < ActiveAd::Base
  READ_FIELDS = %i[
    id account_id ad_strategy_id adlabels bid_strategy boosted_object_id brand_lift_studies budget_rebalance_flag budget_remaining buying_type
    can_create_brand_lift_study can_use_spend_cap configured_status created_time daily_budget effective_status is_skadnetwork_attribution issues_info
    last_budget_toggling_time lifetime_budget name objective pacing_type promoted_object recommendations smart_promotion_type source_campaign source_campaign_id
    special_ad_categories special_ad_category special_ad_category_country spend_cap start_time status stop_time topline_id updated_time
  ].freeze
  BID_STRATEGIES = %w[LOWEST_COST_WITHOUT_CAP LOWEST_COST_WITH_BID_CAP COST_CAP].freeze
  BUYING_TYPES = %w[AUCTION RESERVED].freeze
  CAMPAIGN_OPTIMIZATION_TYPES = %w[NONE ICO_ONLY].freeze
  OBJECTIVES = %w[
    APP_INSTALLS BRAND_AWARENESS CONVERSIONS EVENT_RESPONSES LEAD_GENERATION LINK_CLICKS LOCAL_AWARENESS MESSAGES OFFER_CLAIMS PAGE_LIKES POST_ENGAGEMENT
    PRODUCT_CATALOG_SALES REACH STORE_VISITS VIDEO_VIEWS
  ].freeze
  STATUS = %w[ACTIVE PAUSED DELETED ARCHIVED].freeze
  SPECIAL_AD_CATEGORIES = %w[NONE EMPLOYMENT HOUSING CREDIT ISSUES_ELECTIONS_POLITICS].freeze
  SPECIAL_AD_CATEGORY_COUNTRIES = %w[
    AD AE AF AG AI AL AM AN AO AQ AR AS AT AU AW AX AZ BA BB BD BE BF BG BH BI BJ BL BM BN BO BQ BR BS BT BV BW BY BZ CA CC CD CF CG CH CI CK CL CM CN CO CR CU
    CV CW CX CY CZ DE DJ DK DM DO DZ EC EE EG EH ER ES ET FI FJ FK FM FO FR GA GB GD GE GF GG GH GI GL GM GN GP GQ GR GS GT GU GW GY HK HM HN HR HT HU ID IE IL
    IM IN IO IQ IR IS IT JE JM JO JP KE KG KH KI KM KN KP KR KW KY KZ LA LB LC LI LK LR LS LT LU LV LY MA MC MD ME MF MG MH MK ML MM MN MO MP MQ MR MS MT MU MV
    MW MX MY MZ NA NC NE NF NG NI NL NO NP NR NU NZ OM PA PE PF PG PH PK PL PM PN PR PS PT PW PY QA RE RO RS RU RW SA SB SC SD SE SG SH SI SJ SK SL SM SN SO SR
    SS ST SV SX SY SZ TC TD TF TG TH TJ TK TL TM TN TO TR TT TV TW TZ UA UG UM US UY UZ VA VC VE VG VI VN VU WF WS XK YE YT ZA ZM ZW
  ].freeze

  belongs_to :account
  has_many :ad_sets
  has_many :ads

  # Use aliases to map external API attributes to the ActiveAd object attributes. We especially want to make sure identitfication attributes end with an '_id'
  # suffix. For example 'platform_attribute' should be aliased as 'platform_attribute_id'. This way when we call 'object.platform_attribute_id' we know we're
  # getting back an ID instead of an object.
  #
  # alias_attribute :platform_attribute, :active_ad_attribute
  alias_attribute :adlabels, :ad_labels
  alias_attribute :adset_bid_amounts, :ad_set_bid_amounts
  alias_attribute :adset_budgets, :ad_set_budgets
  alias_attribute :created_time, :created_at
  alias_attribute :updated_time, :updated_at
  alias_attribute :last_budget_toggling_time, :last_budget_toggling_at
  alias_attribute :start_time, :start_at
  alias_attribute :stop_time, :stop_at

  # ActiveAd object attributes.
  attribute :id, :big_integer
  attribute :account_id, :big_integer
  attribute :ad_strategy_id, :big_integer
  attribute :ad_set_budgets, array: true
  attribute :ad_set_bid_amounts
  attribute :ad_labels, array: true
  attribute :bid_strategy, :string
  attribute :boosted_object_id, :big_integer
  attribute :brand_lift_studies, array: true
  attribute :budget_rebalance_flag, :boolean
  attribute :budget_remaining, :big_integer
  attribute :buying_type, :string
  attribute :campaign_optimization_type, :string
  attribute :can_create_brand_lift_study, :boolean
  attribute :can_use_spend_cap, :boolean
  attribute :configured_status, :string
  attribute :created_at, :datetime
  attribute :daily_budget, :big_integer
  attribute :effective_status, :string
  attribute :execution_options, array: true
  attribute :is_skadnetwork_attribution, :boolean
  attribute :is_using_l3_schedule, :boolean
  attribute :iterative_split_test_configs, array: true
  attribute :issues_info, array: true
  attribute :last_budget_toggling_at, :datetime
  attribute :lifetime_budget, :big_integer
  attribute :name, :string
  attribute :objective, :string # default: 'LINK_CLICKS'
  attribute :pacing_type, array: true
  attribute :promoted_object
  attribute :recommendations, array: true
  attribute :smart_promotion_type, :string
  attribute :source_campaign
  attribute :source_campaign_id, :big_integer
  attribute :special_ad_categories, array: true # default: []
  attribute :special_ad_category, :string
  attribute :special_ad_category_country, array: true # default: []
  attribute :spend_cap, :big_integer
  attribute :start_at, :datetime
  attribute :status, :string # default: 'PAUSED'
  attribute :stop_at, :datetime
  attribute :topline_id, :integer
  attribute :updated_at, :datetime
  attribute :upstream_events

  # Use validations which will overwrite the parent class implementations.
  #
  # validates_length_of :title, maximum: 24
  # validates :titles, titles_length: { maximums: [24, 50] }
  validates_presence_of :name, :status, :objective, :special_ad_categories, on: :create

  validates_inclusion_of :bid_strategy, in: BID_STRATEGIES, allow_blank: true, message: validates_inclusion_of_message(BID_STRATEGIES)
  validates_inclusion_of :buying_type, in: BUYING_TYPES, allow_blank: true, message: validates_inclusion_of_message(BUYING_TYPES)
  validates_inclusion_of :campaign_optimization_type, in: CAMPAIGN_OPTIMIZATION_TYPES,
                                                      allow_blank: true,
                                                      message: validates_inclusion_of_message(CAMPAIGN_OPTIMIZATION_TYPES)
  validates_inclusion_of :objective, in: OBJECTIVES, allow_blank: true, message: validates_inclusion_of_message(OBJECTIVES)
  validates_inclusion_of :status, in: STATUS, allow_blank: true, message: validates_inclusion_of_message(STATUS)
  validates_inclusion_of :special_ad_categories, in: SPECIAL_AD_CATEGORIES, on: :create, message: validates_inclusion_of_message(SPECIAL_AD_CATEGORIES)
  validates_inclusion_of :special_ad_category, in: SPECIAL_AD_CATEGORIES,
                                               on: :update,
                                               allow_blank: true,
                                               message: validates_inclusion_of_message(SPECIAL_AD_CATEGORIES)
  validates_inclusion_of :special_ad_category_country, in: SPECIAL_AD_CATEGORY_COUNTRIES,
                                                       allow_blank: true,
                                                       message: validates_inclusion_of_message(SPECIAL_AD_CATEGORY_COUNTRIES)

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
        get: "#{client.base_url}/#{id}/campaigns",
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
      post: "#{client.base_url}/act_#{account_id}/campaigns",
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
    %i[account_id]
  end
end
