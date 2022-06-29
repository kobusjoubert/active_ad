class ActiveAd::Facebook::CustomAudience < ActiveAd::Base
  # References:
  # - [https://developers.facebook.com/docs/marketing-api/reference/custom-audience/]
  # - [https://developers.facebook.com/docs/marketing-api/reference/ad-account/customaudiences/]
  READ_FIELDS = %i[
    id account_id approximate_count customer_file_source data_source delivery_status description external_event_source is_value_based lookalike_audience_ids
    lookalike_spec name operation_status opt_out_link permission_for_actions pixel_id retention_days rule rule_aggregation sharing_status subtype
    time_content_updated time_created time_updated
  ].freeze

  CLAIM_OBJECTIVE = %w[AUTOMOTIVE_MODEL COLLABORATIVE_ADS HOME_LISTING MEDIA_TITLE PRODUCT TRAVEL VEHICLE VEHICLE_OFFER].freeze

  CONTENT_TYPES = %w[
    AUTOMOTIVE_MODEL DESTINATION FLIGHT HOME_LISTING HOTEL JOB LOCAL_SERVICE_BUSINESS LOCATION_BASED_ITEM MEDIA_TITLE OFFLINE_PRODUCT PRODUCT VEHICLE
    VEHICLE_OFFER
  ].freeze

  CUSTOMER_FILE_SOURCES = %w[USER_PROVIDED_ONLY PARTNER_PROVIDED_ONLY BOTH_USER_AND_PARTNER_PROVIDED].freeze

  SUBTYPES = %w[
    CUSTOM WEBSITE APP OFFLINE_CONVERSION CLAIM PARTNER MANAGED VIDEO LOOKALIKE ENGAGEMENT BAG_OF_ACCOUNTS STUDY_RULE_AUDIENCE FOX MEASUREMENT
    REGULATED_CATEGORIES_AUDIENCE
  ].freeze

  belongs_to :account
  belongs_to :pixel

  # Use aliases to map external API attributes to the ActiveAd object attributes. We especially want to make sure identitfication attributes end with an '_id'
  # suffix. For example 'platform_attribute' should be aliased as 'platform_attribute_id'. This way when we call 'object.platform_attribute_id' we know we're
  # getting back an ID instead of an object.
  #
  # alias_attribute :platform_attribute, :active_ad_attribute
  alias_attribute :time_content_updated, :content_updated_at
  alias_attribute :time_created, :created_at
  alias_attribute :time_updated, :updated_at

  # ActiveAd object attributes.
  attribute :id, :big_integer
  attribute :account_id, :big_integer
  attribute :allowed_domains, array: true
  attribute :approximate_count, :integer
  attribute :claim_objective, :string
  attribute :content_type, :string
  attribute :customer_file_source, :string
  attribute :data_source
  attribute :dataset_id, :big_integer
  attribute :delivery_status
  attribute :description, :string
  attribute :enable_fetch_or_create, :boolean
  attribute :event_sources
  attribute :event_source_group, :big_integer
  attribute :external_event_source
  attribute :is_value_based, :boolean
  attribute :lookalike_audience_ids, array: true
  attribute :lookalike_spec
  attribute :name, :string
  attribute :operation_status
  attribute :opt_out_link, :string
  attribute :origin_audience_id, :big_integer
  attribute :permission_for_actions
  attribute :pixel_id, :big_integer
  attribute :prefill, :boolean
  attribute :product_set_id, :big_integer
  attribute :retention_days, :big_integer
  attribute :rule, :string
  attribute :rule_aggregation, :string
  attribute :sharing_status
  attribute :subtype, :string
  attribute :content_updated_at, :integer
  attribute :created_at, :datetime
  attribute :updated_at, :datetime

  # Use validations which will overwrite the parent class implementations.
  #
  # validates_length_of :title, maximum: 24
  # validates :titles, titles_length: { maximums: [24, 50] }
  validates_presence_of :account_id, :name, :subtype, on: :create

  validates_inclusion_of :claim_objective, in: CLAIM_OBJECTIVE, allow_blank: true, message: validates_inclusion_of_message(CLAIM_OBJECTIVE)
  validates_inclusion_of :content_type, in: CONTENT_TYPES, allow_blank: true, message: validates_inclusion_of_message(CONTENT_TYPES)
  validates_inclusion_of :customer_file_source, in: CUSTOMER_FILE_SOURCES, allow_blank: true, message: validates_inclusion_of_message(CUSTOMER_FILE_SOURCES)
  validates_inclusion_of :subtype, in: SUBTYPES, message: validates_inclusion_of_message(SUBTYPES), on: :create

  validates_numericality_of :account_id, greater_than: 0, on: :create
  validates_numericality_of :dataset_id, :origin_audience_id, :pixel_id, :product_set_id, allow_nil: true, greater_than: 0, on: :create
  validates_numericality_of :product_set_id, allow_nil: true, greater_than: 0

  # Use callbacks to execute code that should happen before or after `find`, `create`, `update`, `save`, `destroy`, `link` or `unlink`.
  #
  # before_save :do_something
  # after_destroy :do_something

  class << self
    def index_request(client:, **kwargs)
      params = kwargs.dup
      id, id_key = index_request_id_and_key(params)
      id = "act_#{id}" if id_key == :account_id
      fields = ((params.delete(:fields) || READ_FIELDS) + relational_attributes).uniq

      {
        get: "#{client.base_url}/#{id}/customaudiences",
        params: params.merge(access_token: client.access_token, fields: fields.join(','))
      }
    end

    # Attributes to be requested from the external API which are required by `belongs_to` to work.
    def relational_attributes
      %i[account_id pixel_id]
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
      post: "#{client.base_url}/act_#{account_id}/customaudiences",
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
    super.except('account_id') # Using `account_id` in the request url only.
  end

  def create_response_id(response)
    response.body['id']
  end
end
