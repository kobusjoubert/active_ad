class ActiveAd::Facebook::Page < ActiveAd::Base
  # Reference: [https://developers.facebook.com/docs/graph-api/reference/page/]
  READ_FIELDS = %i[
    id about access_token ad_campaign affiliation app_id artists_we_like attire awards band_interests band_members best_page bio birthday booking_agent built
    business can_checkin can_post category category_list checkins company_overview connected_instagram_account connected_page_backed_instagram_account
    contact_address copyright_attribution_insights copyright_whitelisted_ig_partners country_page_likes cover culinary_team current_location
    delivery_and_pickup_option_info description description_html differently_open_offerings directed_by display_subtext displayed_message_response_time emails
    engagement fan_count featured_video features followers_count food_styles founded general_info general_manager genre global_brand_page_name
    global_brand_root_id has_added_app has_transitioned_to_new_page_experience has_whatsapp_business_number has_whatsapp_number hometown hours impressum
    influences instagram_business_account instant_articles_review_status is_always_open is_chain is_community_page is_eligible_for_branded_content
    is_messenger_bot_get_started_enabled is_messenger_platform_bot is_owned is_permanently_closed is_published is_unclaimed leadgen_tos_acceptance_time
    leadgen_tos_accepted leadgen_tos_accepting_user link location members merchant_id merchant_review_status messaging_feature_status
    messenger_ads_default_icebreakers messenger_ads_default_page_welcome_message messenger_ads_default_quick_replies messenger_ads_quick_replies_type mission
    mpg name name_with_location_descriptor network new_like_count offer_eligible overall_star_rating page_token parent_page parking payment_options
    personal_info personal_interests pharma_safety_info phone pickup_options place_type plot_outline preferred_audience press_contact price_range
    privacy_info_url produced_by products promotion_eligible promotion_ineligible_reason public_transit rating_count recipient record_label release_date
    restaurant_services restaurant_specialties schedule screenplay_by season single_line_address starring start_info store_code store_location_descriptor
    store_number studio supports_donate_button_in_live_video supports_instant_articles talking_about_count temporary_status unread_message_count
    unread_notif_count unseen_message_count username verification_status voip_info website were_here_count whatsapp_number written_by
  ].freeze

  belongs_to :business

  # Use aliases to map external API attributes to the ActiveAd object attributes. We especially want to make sure identitfication attributes end with an '_id'
  # suffix. For example 'platform_attribute' should be aliased as 'platform_attribute_id'. This way when we call 'object.platform_attribute_id' we know we're
  # getting back an ID instead of an object.
  #
  # alias_attribute :platform_attribute, :active_ad_attribute
  alias_attribute :leadgen_tos_acceptance_time, :leadgen_tos_acceptance_at
  alias_attribute :recipient, :recipient_id

  # ActiveAd object attributes.
  attribute :id, :big_integer
  attribute :about, :string
  attribute :access_token, :string
  attribute :ad_campaign
  attribute :affiliation, :string
  attribute :app_id, :big_integer
  attribute :artists_we_like, :string
  attribute :attire, :string
  attribute :awards, :string
  attribute :band_interests, :string
  attribute :band_members, :string
  attribute :best_page
  attribute :bio, :string
  attribute :birthday, :string
  attribute :booking_agent, :string
  attribute :built, :string
  attribute :business
  attribute :business_id, :big_integer
  attribute :can_checkin, :boolean
  attribute :can_post, :boolean
  attribute :category, :string
  attribute :category_list, array: true
  attribute :checkins, :integer
  attribute :company_overview, :string
  attribute :connected_instagram_account
  attribute :connected_page_backed_instagram_account
  attribute :contact_address
  attribute :copyright_attribution_insights, :string
  attribute :copyright_whitelisted_ig_partners, array: true
  attribute :country_page_likes, :big_integer
  attribute :cover
  attribute :culinary_team, :string
  attribute :current_location, :string
  attribute :delivery_and_pickup_option_info, array: true
  attribute :description, :string
  attribute :description_html, :string
  attribute :differently_open_offerings, array: true
  attribute :directed_by, :string
  attribute :display_subtext, :string
  attribute :displayed_message_response_time, :string
  attribute :emails, array: true
  attribute :engagement
  attribute :fan_count, :big_integer
  attribute :featured_video
  attribute :features, :string
  attribute :followers_count, :big_integer
  attribute :food_styles, array: true
  attribute :founded, :string
  attribute :general_info, :string
  attribute :general_manager, :string
  attribute :genre, :string
  attribute :global_brand_page_name, :string
  attribute :global_brand_root_id, :big_integer
  attribute :has_added_app, :boolean
  attribute :has_transitioned_to_new_page_experience, :boolean
  attribute :has_whatsapp_business_number, :boolean
  attribute :has_whatsapp_number, :boolean
  attribute :hometown, :string
  attribute :hours
  attribute :impressum, :string
  attribute :influences, :string
  attribute :instagram_business_account
  attribute :instant_articles_review_status, :string
  attribute :is_always_open, :boolean
  attribute :is_chain, :boolean
  attribute :is_community_page, :boolean
  attribute :is_eligible_for_branded_content, :boolean
  attribute :is_messenger_bot_get_started_enabled, :boolean
  attribute :is_messenger_platform_bot, :boolean
  attribute :is_owned, :boolean
  attribute :is_permanently_closed, :boolean
  attribute :is_published, :boolean
  attribute :is_unclaimed, :boolean
  attribute :leadgen_tos_acceptance_at, :datetime
  attribute :leadgen_tos_accepted, :boolean
  attribute :leadgen_tos_accepting_user
  attribute :link, :string
  attribute :location
  attribute :members, :string
  attribute :merchant_id, :string
  attribute :merchant_review_status, :string
  attribute :messaging_feature_status
  attribute :messenger_ads_default_icebreakers, array: true
  attribute :messenger_ads_default_page_welcome_message
  attribute :messenger_ads_default_quick_replies, array: true
  attribute :messenger_ads_quick_replies_type, :string
  attribute :mission, :string
  attribute :mpg, :string
  attribute :name, :string
  attribute :name_with_location_descriptor, :string
  attribute :network, :string
  attribute :new_like_count, :big_integer
  attribute :offer_eligible, :boolean
  attribute :overall_star_rating, :float
  attribute :page_token, :string
  attribute :parent_page
  attribute :parking
  attribute :payment_options
  attribute :personal_info, :string
  attribute :personal_interests, :string
  attribute :pharma_safety_info, :string
  attribute :phone, :string
  attribute :pickup_options, array: true
  attribute :place_type, :string
  attribute :plot_outline, :string
  attribute :preferred_audience
  attribute :press_contact, :string
  attribute :price_range, :string
  attribute :privacy_info_url, :string
  attribute :produced_by, :string
  attribute :products, :string
  attribute :promotion_eligible, :boolean
  attribute :promotion_ineligible_reason, :string
  attribute :public_transit, :string
  attribute :rating_count, :big_integer
  attribute :recipient_id, :big_integer
  attribute :record_label, :string
  attribute :release_date, :string
  attribute :restaurant_services
  attribute :restaurant_specialties
  attribute :schedule, :string
  attribute :screenplay_by, :string
  attribute :season, :string
  attribute :single_line_address, :string
  attribute :starring, :string
  attribute :start_info
  attribute :store_code, :string
  attribute :store_location_descriptor, :string
  attribute :store_number, :big_integer
  attribute :studio, :string
  attribute :supports_donate_button_in_live_video, :boolean
  attribute :supports_instant_articles, :boolean
  attribute :talking_about_count, :big_integer
  attribute :temporary_status, :string
  attribute :unread_message_count, :big_integer
  attribute :unread_notif_count, :big_integer
  attribute :unseen_message_count, :big_integer
  attribute :username, :string
  attribute :verification_status, :string
  attribute :voip_info
  attribute :website, :string
  attribute :were_here_count, :big_integer
  attribute :whatsapp_number, :string
  attribute :written_by, :string

  # Use callbacks to execute code that should happen before or after `find`, `create`, `update`, `save`, `destroy`, `link` or `unlink`.
  #
  # before_save :do_something
  # after_destroy :do_something
  after_find :set_business_id

  class << self
    def index_request(**kwargs)
      params = kwargs.dup
      id, id_key = index_request_id_and_key(params)

      id = "act_#{id}" if id_key == :account_id
      fields = params.delete(:fields) || READ_FIELDS

      {
        get: "#{client.base_url}/#{id}/pages",
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

  private

  # Attributes to be requested from the external API which are required by `belongs_to` to work.
  def relational_attributes
    %i[business]
  end

  def set_business_id
    assign_attributes(business_id: response.body.dig('business', 'id')) if response.success?
  end
end
