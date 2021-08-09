class ActiveAd::Facebook::Ad < ActiveAd::Base
  # Attributes that clashes with the relational methods.
  #
  #   'adset'
  READ_FIELDS = %i[
    id account_id ad_review_feedback adlabels adset_id bid_amount campaign campaign_id configured_status conversion_domain created_time creative
    effective_status issues_info last_updated_by_app_id name preview_shareable_link recommendations source_ad source_ad_id status tracking_specs updated_time
  ].freeze
  STATUS = %w[ACTIVE PAUSED DELETED ARCHIVED].freeze

  belongs_to :account
  belongs_to :campaign
  belongs_to :ad_set
  belongs_to :ad_creative

  # Use aliases to map external API attributes to the ActiveAd object attributes. We especially want to make sure identitfication attributes end with an '_id'
  # suffix. For example 'platform_attribute' should be aliased as 'platform_attribute_id'. This way when we call 'object.platform_attribute_id' we know we're
  # getting back an ID instead of an object.
  #
  # alias_attribute :platform_attribute, :active_ad_attribute
  alias_attribute :adlabels, :ad_labels
  # alias_attribute :adset, :ad_set # Clashes with the `belongs_to :ad_set` relationship.
  alias_attribute :adset_id, :ad_set_id
  alias_attribute :adset_spec, :ad_set_spec
  alias_attribute :created_time, :created_at
  alias_attribute :draft_adgroup_id, :draft_ad_group_id
  alias_attribute :updated_time, :updated_at

  # ActiveAd object attributes.
  attribute :id, :big_integer
  attribute :account_id, :big_integer
  attribute :ad_creative_id, :big_integer
  attribute :ad_review_feedback
  attribute :ad_labels, array: true
  # attribute :ad_set # Clashes with the `belongs_to :ad_set` relationship.
  attribute :ad_set_id, :big_integer
  attribute :ad_set_spec
  attribute :audience_id, :string
  attribute :bid_amount, :integer
  # attribute :campaign # Clashes with the `belongs_to :campaign` relationship.
  attribute :campaign_id, :big_integer
  attribute :configured_status, :string
  attribute :conversion_domain, :string
  attribute :created_at, :datetime
  attribute :creative
  attribute :date_format, :string
  attribute :display_sequence, :big_integer
  attribute :draft_ad_group_id, :big_integer
  attribute :effective_status, :string
  attribute :engagement_audience, :boolean
  attribute :execution_options, array: true
  attribute :include_demolink_hashes, :boolean
  attribute :issues_info, array: true
  attribute :last_updated_by_app_id, :big_integer
  attribute :name, :string
  attribute :preview_shareable_link, :string
  attribute :priority, :big_integer
  attribute :recommendations, array: true
  attribute :source_ad
  attribute :source_ad_id, :big_integer
  attribute :status, :string # default: 'PAUSED'
  attribute :tracking_specs, array: true
  attribute :updated_at, :datetime

  # Use validations which will overwrite the parent class implementations.
  #
  # validates_length_of :title, maximum: 24
  # validates :titles, titles_length: { maximums: [24, 50] }
  validates_presence_of :name, :status, on: :create

  validates_inclusion_of :status, in: STATUS, allow_blank: true, message: validates_inclusion_of_message(STATUS)

  # Use callbacks to execute code that should happen before or after `create`, `update`, `save` or `destroy`.
  #
  # before_save :do_something
  # after_destroy :do_something
  after_find :set_ad_creative_id

  class << self
    def index_request(**kwargs)
      params = kwargs.dup
      id, id_key = index_request_id_and_key(params)

      id = "act_#{id}" if id_key == :account_id
      fields = params.delete(:fields) || READ_FIELDS

      {
        get: "#{client.base_url}/#{id}/ads",
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
      post: "#{client.base_url}/act_#{account_id}/ads",
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
    %i[account_id campaign_id adset_id creative]
  end

  def set_ad_creative_id
    assign_attributes(ad_creative_id: response.body.dig('creative', 'id')) if response.success?
  end
end
