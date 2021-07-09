class ActiveAd::Facebook::Ad < ActiveAd::Ad
  # Attributes needed for creating and updating.
  attribute :account_id, :string
  attribute :creative
  attribute :status, :string, default: 'PAUSED'

  # platform_attribute <==> active_ad_attribute
  ATTRIBUTES_MAPPING = {
    adset_id: :ad_group_id
  }.freeze

  READ_FIELDS = %w[
    account_id ad_review_feedback adlabels adset_id bid_amount campaign_id configured_status conversion_domain created_time effective_status issues_info
    last_updated_by_app_id name preview_shareable_link recommendations source_ad_id status tracking_specs updated_time
  ].freeze

  validates_presence_of :name, :status, on: :create

  # Use validations which will overwrite the parent class implementations.
  #
  validates_length_of :title, maximum: 24
  # validates :titles, titles_length: { maximums: [24, 50] }

  # Use callbacks to execute code that should happen before or after `create`, `update`, `save` or `destroy`.
  #
  # before_save :do_something
  # after_destroy :do_something

  class << self
    def index_request(**kwargs)
      params = kwargs.dup
      raise ArgumentError, "Expected :ad_group_id to be present, got #{params}" unless (ad_group_id = params.delete(:ad_group_id))

      fields = params.delete(:fields) || READ_FIELDS

      {
        get: "https://graph.facebook.com/v#{client.api_version}/#{ad_group_id}/ads",
        params: params.merge(access_token: client.access_token, fields: fields.join(','))
      }
    end
  end

  def read_request(**kwargs)
    fields = kwargs[:fields] || READ_FIELDS

    {
      get: "https://graph.facebook.com/v#{client.api_version}/#{ad_id}",
      params: { access_token: client.access_token, fields: fields.join(',') }
    }
  end

  def create_request
    {
      post: "https://graph.facebook.com/v#{client.api_version}/act_#{account_id}/ads",
      body: create_request_attributes.merge(access_token: client.access_token)
    }
  end

  def update_request
    {
      post: "https://graph.facebook.com/v#{client.api_version}/#{ad_id}",
      body: update_request_attributes.merge(access_token: client.access_token)
    }
  end

  def delete_request
    {
      delete: "https://graph.facebook.com/v#{client.api_version}/#{ad_id}",
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
end
