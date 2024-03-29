class ActiveAd::Facebook::Account < ActiveAd::Facebook::Base
  # Reference: [https://developers.facebook.com/docs/marketing-api/reference/ad-account/]
  #
  # Requesting the following fields causes status `400` error with messages.
  #
  #   'direct_deals_tos_accepted' => "(#3) Ad Account must be on allowlist"
  #   'has_page_authorized_adaccount' => "(#100) For field 'has_page_authorized_adaccount': The parameter page_id is required"
  #   'show_checkout_experience' => "(#100) For field 'show_checkout_experience': The parameter page_id is required"
  #
  # The 'id' field returns an 'act_' prefixed value, possibly a Facebook hack because they might have needed values to be globally unique ¯\_(ツ)_/¯. When you
  # look at things like 'campaign.account_id' it doesn't return the 'act_' prefixed value. So whenever the 'id' attribute is being set on an object, we remove
  # the prefixed 'act_' value.
  #
  #   'id' => 'act_123'
  #   'account_id' => '123'
  READ_FIELDS = %i[
    id account_id account_status age agency_client_declaration amount_spent balance business business_city business_country_code business_name business_state
    business_street business_street2 business_zip can_create_brand_lift_study capabilities created_time currency disable_reason end_advertiser
    end_advertiser_name extended_credit_invoice_group failed_delivery_checks fb_entity funding_source funding_source_details has_migrated_permissions
    io_number is_attribution_spec_system_default is_direct_deals_enabled is_in_3ds_authorization_enabled_market is_notifications_enabled is_personal
    is_prepay_account is_tax_id_required line_numbers media_agency min_campaign_group_spend_cap min_daily_budget name offsite_pixels_tos_accepted owner
    partner rf_spec spend_cap tax_id tax_id_status tax_id_type timezone_id timezone_name timezone_offset_hours_utc tos_accepted user_tasks user_tos_accepted
  ].freeze

  ISO_4217_CURRENCY_CODES = %w[
    AED AFN ALL AMD ANG AOA ARS AUD AWG AZN BAM BBD BDT BGN BHD BIF BMD BND BOB BOV BRL BSD BTN BWP BYN BZD CAD CDF CHE CHF CHW CLF CLP CNY COP COU CRC CUC CUP
    CVE CZK DJF DKK DOP DZD EGP ERN ETB EUR FJD FKP GBP GEL GHS GIP GMD GNF GTQ GYD HKD HNL HRK HTG HUF IDR ILS INR IQD IRR ISK JMD JOD JPY KES KGS KHR KMF KPW
    KRW KWD KYD KZT LAK LBP LKR LRD LSL LYD MAD MDL MGA MKD MMK MNT MOP MRU MUR MVR MWK MXN MXV MYR MZN NAD NGN NIO NOK NPR NZD OMR PAB PEN PGK PHP PKR PLN PYG
    QAR RON RSD RUB RWF SAR SBD SCR SDG SEK SGD SHP SLL SOS SRD SSP STN SVC SYP SZL THB TJS TMT TND TOP TRY TTD TWD TZS UAH UGX USD USN UYI UYU UYW UZS VES VND
    VUV WST XAF XAG XAU XBA XBB XBC XBD XCD XDR XOF XPD XPF XPT XSU XTS XUA XXX YER ZAR ZMW ZWL
  ].freeze

  belongs_to :business
  has_many :campaigns
  has_many :custom_audiences
  has_many :ad_sets
  has_many :ads
  has_many :ad_creatives
  has_many :pixels
  has_many :saved_audiences

  # Use aliases to map external API attributes to the ActiveAd object attributes. We especially want to make sure identitfication attributes end with an '_id'
  # suffix. For example 'platform_attribute' should be aliased as 'platform_attribute_id'. This way when we call 'object.platform_attribute_id' we know we're
  # getting back an ID instead of an object.
  #
  # alias_attribute :platform_attribute, :active_ad_attribute
  alias_attribute :account_id, :id
  alias_attribute :account_status, :status
  alias_attribute :created_time, :created_at
  alias_attribute :end_advertiser, :end_advertiser_id
  alias_attribute :funding_source, :funding_source_id
  alias_attribute :media_agency, :media_agency_id
  alias_attribute :owner, :owner_id
  alias_attribute :partner, :partner_id

  # ActiveAd object attributes.
  attribute :id, :big_integer
  attribute :ad_account_promotable_objects
  attribute :age, :float
  attribute :agency_client_declaration
  attribute :amount_spent, :big_integer
  attribute :balance, :big_integer
  attribute :business # Clashes with the `belongs_to :business` relationship. Access using `attributes['business']` => {'name'=>'Business Name', 'id'=>'123'}
  attribute :business_city, :string
  attribute :business_country_code, :string
  attribute :business_id, :big_integer
  attribute :business_info
  attribute :business_name, :string
  attribute :business_state, :string
  attribute :business_street, :string
  attribute :business_street2, :string
  attribute :business_zip, :string
  attribute :can_create_brand_lift_study, :boolean
  attribute :capabilities, array: true
  attribute :created_at, :datetime
  attribute :currency, :string # default: 'USD'
  attribute :direct_deals_tos_accepted, :boolean
  attribute :disable_reason, :integer
  attribute :end_advertiser_id, :string # default: 'NONE'
  attribute :end_advertiser_name, :string
  attribute :extended_credit_invoice_group
  attribute :failed_delivery_checks, array: true
  attribute :fb_entity, :integer
  attribute :funding_source_id, :big_integer
  attribute :funding_source_details
  attribute :has_migrated_permissions, :boolean
  attribute :has_page_authorized_adaccount, :boolean
  attribute :io_number, :big_integer
  attribute :is_attribution_spec_system_default, :boolean
  attribute :is_direct_deals_enabled, :boolean
  attribute :is_in_3ds_authorization_enabled_market, :boolean
  attribute :is_in_middle_of_local_entity_migration, :boolean
  attribute :is_notifications_enabled, :boolean
  attribute :is_personal, :integer
  attribute :is_prepay_account, :boolean
  attribute :is_tax_id_required, :boolean
  attribute :line_numbers, array: true
  attribute :media_agency_id, :string # default: 'NONE'
  attribute :min_campaign_group_spend_cap, :big_integer
  attribute :min_daily_budget, :integer
  attribute :name, :string
  attribute :offsite_pixels_tos_accepted, :boolean
  attribute :owner_id, :big_integer
  attribute :partner_id, :string # default: 'NONE'
  attribute :rf_spec
  attribute :show_checkout_experience, :boolean
  attribute :spend_cap, :big_integer
  attribute :spend_cap_action, :string
  attribute :status, :integer
  attribute :tax_id, :string
  attribute :tax_id_status, :integer
  attribute :tax_id_type, :string
  attribute :timezone_id, :integer # default: 474
  attribute :timezone_name, :string
  attribute :timezone_offset_hours_utc, :float
  attribute :tos_accepted
  attribute :user_tasks, array: true
  attribute :user_tos_accepted

  # Use validations which will overwrite the parent class implementations.
  #
  # validates_presence_of :title
  # validates_length_of :title, maximum: 24
  # validates :titles, titles_length: { maximums: [24, 50] }
  validates_presence_of :name, :currency, :timezone_id, :end_advertiser_id, :media_agency_id, :partner_id, :business_id, on: :create

  validates_inclusion_of :currency, in: ISO_4217_CURRENCY_CODES, allow_blank: true, message: validates_inclusion_of_message(ISO_4217_CURRENCY_CODES)

  validates_numericality_of :timezone_id, allow_nil: true
  validates_numericality_of :business_id, allow_nil: true, greater_than: 0

  # Use callbacks to execute code that should happen before or after `find`, `create`, `update`, `save`, `destroy`, `link` or `unlink`.
  #
  # before_save :do_something
  # after_destroy :do_something
  after_find :set_business_id

  class << self
    def index_request(client:, **kwargs)
      params = kwargs.dup
      id, id_key = index_request_id_and_key(params)
      id = "act_#{id}" if id_key == :account_id
      fields = ((params.delete(:fields) || READ_FIELDS) + relational_attributes).uniq

      {
        get: "#{client.base_url}/#{id}/adaccounts",
        params: params.merge(access_token: client.access_token, fields: fields.join(','))
      }
    end

    # Attributes to be requested from the external API which are required by `belongs_to` to work.
    def relational_attributes
      %i[business]
    end
  end

  def read_request(**kwargs)
    params = kwargs.dup
    fields = ((params.delete(:fields) || READ_FIELDS) + relational_attributes).uniq

    {
      get: "#{client.base_url}/act_#{id}",
      params: params.merge(access_token: client.access_token, fields: fields.join(','))
    }
  end

  # On create_request & update_request.
  #
  # end_advertiser, media_agency & partner: Must be a Facebook Page Alias, Facebook Page ID or an Facebook App ID. In absence of one, you can use NONE or
  # UNFOUND. Once it is set to any values other than NONE or UNFOUND, it cannot be modified any more.
  #
  # end_advertiser: The entity the ads will target.
  # media_agency: The agency, this could be your own business.
  # partner: This could be Facebook Marketing Partner, if there is one.
  def create_request
    # /:business_id/adaccount
    # /:business_id/ad_accounts
    # /:business_id/owned_ad_accounts
    {
      post: "#{client.base_url}/#{business_id}/adaccount",
      body: create_request_attributes.merge(access_token: client.access_token)
    }
  end

  def update_request
    {
      post: "#{client.base_url}/act_#{id}",
      body: update_request_attributes.merge(access_token: client.access_token)
    }
  end

  def delete_request
    raise ActiveAd::RequestError, 'Cannot delete an ad account'
  end

  # Remove 'act_' prefixes from the 'id' attribute.
  def id=(value)
    value = value.remove('act_') if value.is_a?(String)
    super
  end

  private

  def create_response_id(response)
    response.body['id']
  end

  def set_business_id
    assign_attributes(business_id: attributes.dig('business', 'id')) unless stale && business_id
  end

  # Remove 'act_' prefixes from the 'id' attribute.
  def assign_attributes(attributes = {})
    attributes = attributes.deep_stringify_keys
    attributes['id'] = attributes['id'].remove('act_') if attributes['id'].is_a?(String)
    super(attributes)
  end
end
