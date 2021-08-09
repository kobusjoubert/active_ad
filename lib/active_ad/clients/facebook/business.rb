class ActiveAd::Facebook::Business < ActiveAd::Base
  # Requesting the following fields causes status `400` error with messages.
  #
  #   'collaborative_ads_managed_partner_eligibility' => "(#100) The parameter catalog_id is required"
  #   'collaborative_ads_managed_partner_business_info' => "(#10) Permission Denied"
  READ_FIELDS = %i[
    id block_offline_analytics created_by created_time extended_updated_time is_hidden link name payment_account_id primary_page profile_picture_uri timezone_id
    two_factor_type updated_by updated_time verification_status vertical vertical_id
  ].freeze
  UNLINK_REQUEST_MAPPING = {
    ad_account_id: { path: 'ad_accounts', param: :adaccount_id },
    agency_id: { path: 'agencies', param: :business },
    client_id: { path: 'clients', param: :business },
    instagram_account_id: { path: 'instagram_accounts', param: :instagram_account },
    owned_business_id: { path: 'owned_businesses', param: :client_id },
    page_id: { path: 'pages', param: :page_id }
  }.freeze
  SURVEY_BUSINESS_TYPES = %w[AGENCY ADVERTISER APP_DEVELOPER PUBLISHER].freeze
  VERTICALS = %w[
    ADVERTISING AUTOMOTIVE CONSUMER_PACKAGED_GOODS ECOMMERCE EDUCATION ENERGY_AND_UTILITIES ENTERTAINMENT_AND_MEDIA FINANCIAL_SERVICES GAMING
    GOVERNMENT_AND_POLITICS MARKETING ORGANIZATIONS_AND_ASSOCIATIONS PROFESSIONAL_SERVICES RETAIL TECHNOLOGY TELECOM TRAVEL NON_PROFIT RESTAURANT HEALTH LUXURY
    OTHER
  ].freeze

  has_many :accounts

  # Use aliases to map external API attributes to the ActiveAd object attributes. We especially want to make sure identitfication attributes end with an '_id'
  # suffix. For example 'platform_attribute' should be aliased as 'platform_attribute_id'. This way when we call 'object.platform_attribute_id' we know we're
  # getting back an ID instead of an object.
  #
  # alias_attribute :platform_attribute, :active_ad_attribute
  alias_attribute :created_time, :created_at
  alias_attribute :extended_updated_time, :extended_updated_at
  alias_attribute :updated_time, :updated_at

  # ActiveAd object attributes.
  attribute :id, :big_integer
  attribute :block_offline_analytics, :boolean
  attribute :child_business_external_id, :string
  attribute :collaborative_ads_managed_partner_business_info
  attribute :collaborative_ads_managed_partner_eligibility
  attribute :created_by # {"id"=>"123", "name"=>"Kobus Joubert", "business"=>{"id"=>"123", "name"=>"Business Name"}}
  attribute :created_at, :datetime
  attribute :email, :string
  attribute :extended_updated_at, :datetime
  attribute :is_hidden, :boolean
  attribute :link, :string
  attribute :name, :string
  attribute :payment_account_id, :big_integer
  attribute :primary_page # {"name"=>"Page Name", "id"=>"123"}
  attribute :profile_picture_uri, :string
  attribute :sales_rep_email, :string
  attribute :survey_business_type, :string
  attribute :survey_num_assets, :big_integer
  attribute :survey_num_people, :big_integer
  attribute :timezone_id, :big_integer
  attribute :two_factor_type, :string
  attribute :updated_by # {"id"=>"123", "name"=>"Kobus Joubert", "business"=>{"id"=>"123", "name"=>"Business Name"}}
  attribute :updated_at, :datetime
  attribute :user_id, :big_integer
  attribute :verification_status, :string
  attribute :vertical, :string
  attribute :vertical_id, :integer

  # Use validations which will overwrite the parent class implementations.
  #
  # validates_length_of :title, maximum: 24
  # validates :titles, titles_length: { maximums: [24, 50] }
  validates_presence_of :name, :vertical, on: :create

  validates_inclusion_of :survey_business_type, in: SURVEY_BUSINESS_TYPES, allow_blank: true, message: validates_inclusion_of_message(SURVEY_BUSINESS_TYPES)
  validates_inclusion_of :vertical, in: VERTICALS, allow_blank: true, message: validates_inclusion_of_message(VERTICALS)

  validates_numericality_of :primary_page, allow_nil: true, greater_than: 0, on: :create
  validates_numericality_of :timezone_id, allow_nil: true
  validates_numericality_of :survey_num_assets, :survey_num_people, allow_nil: true, greater_than: 0

  def read_request(**kwargs)
    params = kwargs.dup
    fields = ((params.delete(:fields) || READ_FIELDS) + relational_attributes).uniq

    {
      get: "#{client.base_url}/#{id}",
      params: params.merge(access_token: client.access_token, fields: fields.join(','))
    }
  end

  def create_request
    ActiveAd.logger.warn("Calling untested endpoint #{self.class}##{__method__}")

    {
      post: "#{client.base_url}/#{user_id}/businesses",
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
    raise ActiveAd::RequestError, 'Cannot delete a business'
  end

  # Request examples.
  #
  #   business.unlink(ad_account_id: '1')
  #   business.unlink(agency_id: '1')
  #   business.unlink(client_id: '1')
  #   business.unlink(instagram_account_id: '1')
  #   business.unlink(ownded_business_id: '1')
  #   business.unlink(page_id: '1')
  def unlink_request(**kwargs)
    params = kwargs.dup.symbolize_keys
    key = (UNLINK_REQUEST_MAPPING.keys & kwargs.keys).first

    unless (params[UNLINK_REQUEST_MAPPING[key][:param]] = params.delete(key))
      raise ArgumentError, "missing keyword: must include one of #{UNLINK_REQUEST_MAPPING.keys}; received #{kwargs}"
    end

    {
      delete: "#{client.base_url}/#{id}/#{UNLINK_REQUEST_MAPPING[key][:path]}",
      params: params.merge(access_token: client.access_token)
    }
  end

  private

  def create_response_id(response)
    response.body['id']
  end

  # List all the relational attributes required for `belongs_to` to know which parent to request.
  def relational_attributes
    %i[]
  end
end
