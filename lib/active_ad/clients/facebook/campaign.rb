class ActiveAd::Facebook::Campaign < ActiveAd::Base
  READ_FIELDS = %i[
    account_id ad_strategy_id adlabels bid_strategy boosted_object_id brand_lift_studies budget_rebalance_flag budget_remaining buying_type
    can_create_brand_lift_study can_use_spend_cap configured_status created_time daily_budget effective_status id is_skadnetwork_attribution issues_info
    last_budget_toggling_time lifetime_budget name objective pacing_type promoted_object recommendations smart_promotion_type source_campaign source_campaign_id
    special_ad_categories special_ad_category special_ad_category_country spend_cap start_time status stop_time topline_id updated_time
  ].freeze

  belongs_to :account
  has_many :ad_sets

  attribute :id, :big_integer

  # Use aliases to map external API attributes to the ActiveAd object attributes. We especially want to make sure identitfication attributes end with an '_id'
  # suffix. For example 'platform_attribute' should be aliased as 'platform_attribute_id'. This way when we call 'object.platform_attribute_id' we know we're
  # getting back an ID instead of an object.
  #
  # alias_attribute :platform_attribute, :active_ad_attribute
  alias_attribute :adlabels, :ad_labels
  alias_attribute :created_time, :created_at
  alias_attribute :updated_time, :updated_at

  # ActiveAd object attributes.
  attribute :account_id, :big_integer
  attribute :ad_strategy_id, :big_integer
  attribute :ad_labels, array: true
  attribute :bid_strategy, :string
  attribute :boosted_object_id, :big_integer
  attribute :brand_lift_studies, array: true
  attribute :budget_rebalance_flag, :boolean
  attribute :budget_remaining, :big_integer
  attribute :buying_type, :string
  attribute :can_create_brand_lift_study, :boolean
  attribute :can_use_spend_cap, :boolean
  attribute :configured_status, :string
  attribute :created_at, :datetime
  attribute :daily_budget, :big_integer
  attribute :effective_status, :string
  attribute :is_skadnetwork_attribution, :boolean
  attribute :issues_info, array: true
  attribute :last_budget_toggling_time, :datetime
  attribute :lifetime_budget, :big_integer
  attribute :name, :string
  attribute :objective, :string # , default: 'LINK_CLICKS'
  attribute :pacing_type, array: true
  attribute :promoted_object
  attribute :recommendations, array: true
  attribute :smart_promotion_type, :string
  attribute :source_campaign
  attribute :source_campaign_id, :big_integer
  attribute :special_ad_categories, array: true # , default: []
  attribute :special_ad_category, :string
  attribute :special_ad_category_country, array: true # , default: []
  attribute :spend_cap, :big_integer
  attribute :start_time, :datetime
  attribute :status, :string # , default: 'PAUSED'
  attribute :stop_time, :datetime
  attribute :topline_id, :integer
  attribute :updated_at, :datetime

  # Use validations which will overwrite the parent class implementations.
  #
  # validates_length_of :title, maximum: 24
  # validates :titles, titles_length: { maximums: [24, 50] }
  validates_presence_of :name, :status, :objective, on: :create
  validates_presence_of :special_ad_categories, allow_blank: true, on: :create

  # Use callbacks to execute code that should happen before or after `create`, `update`, `save` or `destroy`.
  #
  # before_save :do_something
  # after_destroy :do_something

  class << self
    def index_request(**kwargs)
      params = kwargs.dup
      raise ArgumentError, "Expected :account_id to be present, got #{params}" unless (account_id = params.delete(:account_id))

      fields = params.delete(:fields) || READ_FIELDS

      {
        get: "https://graph.facebook.com/v#{client.api_version}/act_#{account_id}/campaigns",
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
      post: "https://graph.facebook.com/v#{client.api_version}/act_#{account_id}/campaigns",
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
    [:account_id]
  end
end
