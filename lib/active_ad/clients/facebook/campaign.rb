class ActiveAd::Facebook::Campaign < ActiveAd::Base
  # platform_attribute <==> active_ad_attribute
  #
  # Both `effective_status` and `status` are supplied by the external API, so mapping `effective_status: :status` will cause conflicts.
  ATTRIBUTES_MAPPING = {}.freeze

  READ_FIELDS = %w[
    ad_strategy_id adlabels bid_strategy budget_remaining buying_type can_use_spend_cap configured_status created_time daily_budget effective_status issues_info
    last_budget_toggling_time lifetime_budget name objective pacing_type promoted_object source_campaign source_campaign_id special_ad_categories
    special_ad_category special_ad_category_country spend_cap start_time status stop_time updated_time
  ].freeze

  belongs_to :account
  has_many :ad_sets

  # Identification attributes.
  alias_method :campaign_id, :id

  # Relation attributes.
  attribute :account_id, :string

  # Titles and descriptions attributes.
  attribute :name, :string

  # Other attributes.
  attribute :bid_strategy, :string
  attribute :objective, :string, default: 'LINK_CLICKS'
  attribute :special_ad_categories, array: true, default: []
  attribute :status, :string, default: 'PAUSED'

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
      get: "https://graph.facebook.com/v#{client.api_version}/#{campaign_id}",
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
      post: "https://graph.facebook.com/v#{client.api_version}/#{campaign_id}",
      body: update_request_attributes.merge(access_token: client.access_token)
    }
  end

  def delete_request
    {
      delete: "https://graph.facebook.com/v#{client.api_version}/#{campaign_id}",
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
