class ActiveAd::Facebook::Account < ActiveAd::Base
  # Requesting `direct_deals_tos_accepted` causes a status `400` with message `(#3) Ad Account must be on allowlist`.
  #
  # The `id` field returnes a `act_` prefixed value, possibly a Facebook hack because they needed the values to be globally unique. When you look at things
  # like `campaign.account_id` it doesn't return the `act_` prefixed value. So whenever the `id` attribute is being set on an object, we remove the prefixed
  # `act_` value.
  #
  #   'id' => 'act_123'
  #   'account_id' => '123'
  READ_FIELDS = %i[
    account_id account_status age amount_spent balance business_city business_country_code business_name business_state business_street business_street2
    business_zip capabilities created_time currency disable_reason end_advertiser end_advertiser_name failed_delivery_checks funding_source
    funding_source_details id is_direct_deals_enabled is_notifications_enabled is_personal is_prepay_account media_agency min_campaign_group_spend_cap
    min_daily_budget name offsite_pixels_tos_accepted owner partner rf_spec spend_cap timezone_id timezone_name timezone_offset_hours_utc tos_accepted
    user_tos_accepted
  ].freeze

  has_many :campaigns

  # Identification attributes.
  attribute :account_id, :string

  # Titles and descriptions attributes.
  attribute :name, :string

  # Other attributes.
  attribute :business_id, :string
  attribute :currency, :string
  attribute :end_advertiser_id, :string
  attribute :media_agency_id, :string
  attribute :partner_id, :string
  attribute :status, :string
  attribute :timezone_id, :integer

  # Use aliases to map external API attributes to the object attributes.
  #
  # alias_attribute :platform_attribute, :active_ad_attribute
  alias_attribute :account_status, :status
  alias_attribute :end_advertiser, :end_advertiser_id
  alias_attribute :media_agency, :media_agency_id
  alias_attribute :partner, :partner_id

  # Use validations which will overwrite the parent class implementations.
  #
  # validates_presence_of :title
  # validates_length_of :title, maximum: 24
  # validates :titles, titles_length: { maximums: [24, 50] }

  # Use callbacks to execute code that should happen before or after `create`, `update`, `save` or `destroy`.
  #
  # before_save :do_something
  # after_destroy :do_something

  def read_request(**kwargs)
    params = kwargs.dup
    fields = ((params.delete(:fields) || READ_FIELDS) + relational_attributes).uniq

    {
      get: "https://graph.facebook.com/v#{client.api_version}/act_#{id}",
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
  #
  # # TODO: Make more elegant.
  # def create_request
  #   {
  #     post: "https://graph.facebook.com/v#{client.api_version}/#{business_id}/adaccount",
  #     body: {
  #       access_token: client.access_token,
  #       name: name,
  #       timezone_id: timezone_id || 474,
  #       currency: (currency.presence || 'USD').to_s,
  #       end_advertiser: (end_advertiser_id.presence || 'NONE').to_s,
  #       media_agency: (media_agency_id.presence || end_advertiser_id.presence || 'NONE').to_s,
  #       partner: (partner_id.presence || 'NONE').to_s
  #     }
  #   }
  # end

  # # TODO: Make more elegant.
  # def update_request
  #   # name: name,
  #   # end_advertiser_id: (end_advertiser_id.presence || 'NONE').to_s,
  #   # spend_cap: 100.00,
  #   # spend_cap_action: 'reset'
  #   {
  #     post: "https://graph.facebook.com/v#{client.api_version}/act_#{account_id}",
  #     body: update_request_attributes.merge(access_token: client.access_token)
  #   }
  # end

  def delete_request
    raise ActiveAd::RequestError, 'Cannot delete an ad account'
  end

  private

  # List all the relational attributes required for `belongs_to` to know which parent to request.
  def relational_attributes
    []
  end

  def assign_attributes(attributes = {})
    attributes['id'] = attributes['id'].remove('act_') if attributes.has_key?('id')
    super(attributes)
  end
end
