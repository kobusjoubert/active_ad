class ActiveAd::Facebook::AdCreative < ActiveAd::Base
  # Reference: [https://developers.facebook.com/docs/marketing-api/reference/ad-creative/]
  #
  # Requesting the following fields causes status `400` error with messages.
  #
  #   'referral_id' => "(#3) User must be on allowlist"
  READ_FIELDS = %i[
    id account_id actor_id adlabels applink_treatment asset_feed_spec authorization_category body branded_content_sponsor_page_id bundle_folder_id
    call_to_action_type categorization_criteria category_media_source destination_set_id dynamic_ad_voice effective_authorization_category
    effective_instagram_media_id effective_instagram_story_id effective_object_story_id enable_direct_install enable_launch_instant_app image_crops
    image_hash image_url instagram_actor_id instagram_permalink_url instagram_story_id instagram_user_id interactive_components_spec
    link_destination_display_url link_og_id link_url messenger_sponsored_message name object_id object_store_url object_story_id object_story_spec object_type
    object_url place_page_set_id platform_customizations playable_asset_id portrait_customizations product_set_id recommender_settings source_instagram_media_id
    status template_url template_url_spec thumbnail_url title url_tags use_page_actor_override video_id
  ].freeze

  STATUS = %w[ACTIVE IN_PROCESS WITH_ISSUES DELETED].freeze

  belongs_to :account

  # Use aliases to map external API attributes to the ActiveAd object attributes. We especially want to make sure identitfication attributes end with an '_id'
  # suffix. For example 'platform_attribute' should be aliased as 'platform_attribute_id'. This way when we call 'object.platform_attribute_id' we know we're
  # getting back an ID instead of an object.
  #
  # alias_attribute :platform_attribute, :active_ad_attribute
  alias_attribute :adlabels, :ad_labels

  # ActiveAd object attributes.
  attribute :id, :big_integer
  attribute :account_id, :big_integer
  attribute :actor_id, :big_integer
  attribute :ad_labels, array: true
  attribute :applink_treatment, :string
  attribute :asset_feed_spec
  attribute :authorization_category, :string
  attribute :body, :string
  attribute :branded_content_sponsor_page_id, :big_integer
  attribute :bundle_folder_id, :big_integer
  attribute :call_to_action_type, :string
  attribute :categorization_criteria, :string
  attribute :category_media_source, :string
  attribute :destination_set_id, :big_integer
  attribute :dynamic_ad_voice, :string
  attribute :effective_authorization_category, :string
  attribute :effective_instagram_media_id, :big_integer
  attribute :effective_instagram_story_id, :big_integer
  attribute :effective_object_story_id, :string # '123_456'
  attribute :enable_direct_install, :boolean
  attribute :enable_launch_instant_app, :boolean
  attribute :image_crops
  attribute :image_hash, :string
  attribute :image_url, :string
  attribute :instagram_actor_id, :big_integer
  attribute :instagram_permalink_url, :string
  attribute :instagram_story_id, :big_integer
  attribute :instagram_user_id, :big_integer
  attribute :interactive_components_spec
  attribute :link_destination_display_url, :string
  attribute :link_og_id, :big_integer
  attribute :link_url, :string
  attribute :messenger_sponsored_message, :string
  attribute :name, :string
  attribute :object_id, :big_integer
  attribute :object_store_url, :string
  attribute :object_story_id, :string # '123_456'
  attribute :object_story_spec
  attribute :object_type, :string
  attribute :object_url, :string
  attribute :place_page_set_id, :big_integer
  attribute :platform_customizations
  attribute :playable_asset_id, :big_integer
  attribute :portrait_customizations
  attribute :product_set_id, :big_integer
  attribute :recommender_settings
  attribute :referral_id, :big_integer
  attribute :source_instagram_media_id, :big_integer
  attribute :status, :string
  attribute :template_url, :string
  attribute :template_url_spec
  attribute :thumbnail_url, :string
  attribute :title, :string
  attribute :url_tags, :string
  attribute :use_page_actor_override, :boolean
  attribute :video_id, :big_integer

  # Use validations which will overwrite the parent class implementations.
  #
  # validates_length_of :title, maximum: 24
  # validates :titles, titles_length: { maximums: [24, 50] }
  validates_presence_of :name, :account_id, :object_story_spec, on: :create

  validates_inclusion_of :status, in: STATUS, allow_blank: true, message: validates_inclusion_of_message(STATUS)

  validates_numericality_of :account_id, greater_than: 0, on: :create

  # Use callbacks to execute code that should happen before or after `find`, `create`, `update`, `save`, `destroy`, `link` or `unlink`.
  #
  # before_save :do_something
  # after_destroy :do_something
  after_destroy :check_response_success

  class << self
    def index_request(client:, **kwargs)
      params = kwargs.dup
      id, id_key = index_request_id_and_key(params)
      id = "act_#{id}" if id_key == :account_id
      fields = ((params.delete(:fields) || READ_FIELDS) + relational_attributes).uniq

      {
        get: "#{client.base_url}/#{id}/adcreatives",
        params: params.merge(access_token: client.access_token, fields: fields.join(','))
      }
    end

    # Attributes to be requested from the external API which are required by `belongs_to` to work.
    def relational_attributes
      %i[account_id]
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
      post: "#{client.base_url}/act_#{account_id}/adcreatives",
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

  def check_response_success
    raise ActiveAd::RecordNotDeleted if response.body['success'] == false
  end
end
