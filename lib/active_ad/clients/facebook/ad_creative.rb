class ActiveAd::Facebook::AdCreative < ActiveAd::Base
  # Requesting `referral_id` causes a status `400` with message `(#3) User must be on allowlist`.
  READ_FIELDS = %i[
    account_id actor_id applink_treatment asset_feed_spec authorization_category body branded_content_sponsor_page_id bundle_folder_id call_to_action_type
    categorization_criteria category_media_source destination_set_id dynamic_ad_voice effective_authorization_category effective_object_story_id
    enable_direct_install enable_launch_instant_app image_crops image_hash image_url interactive_components_spec link_destination_display_url link_og_id
    link_url messenger_sponsored_message name object_id object_store_url object_story_id object_story_spec object_type object_url place_page_set_id
    platform_customizations playable_asset_id portrait_customizations product_set_id recommender_settings status template_url template_url_spec thumbnail_url
    title url_tags use_page_actor_override video_id
  ].freeze

  belongs_to :ad

  # Relation attributes.
  attribute :ad_id, :string

  # Titles and descriptions attributes.
  attribute :name, :string

  # Other attributes.
  attribute :object_story_spec
  attribute :account_id, :string

  # Use aliases to map external API attributes to the object attributes.
  #
  # alias_attribute :platform_attribute, :active_ad_attribute
  #
  # Both `effective_status` and `status` are supplied by the external API, so `alias_attribute :effective_status, :status` will cause conflicts.
  alias_attribute :body, :description

  validates_presence_of :name, on: :create

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
      raise ArgumentError, "missing keyword: :ad_id; received #{params}" unless (ad_id = params.delete(:ad_id))

      fields = params.delete(:fields) || READ_FIELDS

      {
        get: "https://graph.facebook.com/v#{client.api_version}/#{ad_id}/adcreatives",
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
      post: "https://graph.facebook.com/v#{client.api_version}/act_#{account_id}/adcreatives",
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
    [:ad_id]
  end
end
