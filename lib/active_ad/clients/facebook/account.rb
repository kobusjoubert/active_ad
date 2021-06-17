class ActiveAd::Facebook::Account < ActiveAd::Account
  attr_accessor :business_id, :currency, :fields, :media_agency_id, :end_advertiser_id, :partner_id, :timezone_id

  READ_FIELDS = %w[name timezone_id spend_cap tos_accepted user_tos_accepted offsite_pixels_tos_accepted amount_spent balance currency
                   min_campaign_group_spend_cap min_daily_budget media_agency end_advertiser end_advertiser_name funding_source funding_source_details
                   is_prepay_account is_notifications_enabled is_personal disable_reason business business_name business_country_code business_state
                   business_city business_street business_street2 business_zip capabilities]

  ATTRIBUTES_MAPPING = {
    end_advertiser: :end_advertiser_id,
    media_agency: :media_agency_id,
    partner: :partner_id
  }

  # Must be able to use your own validations, taking precedence over what the interface supplies.
  #
  # validates_length_of :title, maximum: 24
  # validates :titles, titles_length: { maximums: [24, 50] }

  # Must be able to use your own callbacks.
  #
  # before_save :do_something
  # after_destroy :do_something

  def read_request
    ActiveAd.connection.get("https://graph.facebook.com/v#{api_version}/act_#{account_id}", {
      access_token: access_token,
      fields: (fields || READ_FIELDS).join(',')
    })
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
  # TODO: Make more elegant.
  # def create_request
  #   ActiveAd.connection.post("https://graph.facebook.com/v#{api_version}/#{business_id}/adaccount", {
  #     access_token: access_token,
  #     name: name,
  #     timezone_id: timezone_id || 474,
  #     currency: (currency.presence || 'USD').to_s,
  #     end_advertiser: (end_advertiser_id.presence || 'NONE').to_s,
  #     media_agency: (media_agency_id.presence || end_advertiser_id.presence || 'NONE').to_s,
  #     partner: (partner_id.presence || 'NONE').to_s
  #   })
  # end

  # TODO: Make more elegant.
  # def update_request
  #   # name: name,
  #   # end_advertiser_id: (end_advertiser_id.presence || 'NONE').to_s,
  #   # spend_cap: 100.00,
  #   # spend_cap_action: 'reset'
  #   ActiveAd.connection.post("https://graph.facebook.com/v#{api_version}/act_#{account_id}", {
  #     access_token: access_token
  #   }.merge(update_attributes))
  # end

  def delete_request
    raise ActiveAd::RequestError, 'Cannot delete an ad account'
  end
end
