class ActiveAd::Facebook::Ad < ActiveAd::Base
  READ_FIELDS = %i[
    account_id ad_review_feedback adlabels adset_id bid_amount campaign_id configured_status conversion_domain created_time effective_status issues_info
    last_updated_by_app_id name preview_shareable_link recommendations source_ad_id status tracking_specs updated_time
  ].freeze

  belongs_to :ad_set
  has_many :ad_creatives

  # Relation attributes.
  attribute :account_id, :string
  attribute :ad_set_id, :string

  # Titles and descriptions attributes.
  attribute :name, :string

  # Other attributes.
  attribute :title, :string
  attribute :titles, array: true
  attribute :creative
  attribute :description, :string
  attribute :descriptions, array: true
  attribute :status, :string, default: 'PAUSED'
  attribute :type, :string

  # Use aliases to map external API attributes to the object attributes.
  #
  # alias_attribute :platform_attribute, :active_ad_attribute
  #
  # Both `effective_status` and `status` are supplied by the external API, so `alias_attribute :effective_status, :status` will cause conflicts.
  alias_attribute :adset_id, :ad_set_id

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
      raise ArgumentError, "Expected :ad_set_id to be present, got #{params}" unless (ad_set_id = params.delete(:ad_set_id))

      fields = params.delete(:fields) || READ_FIELDS

      {
        get: "https://graph.facebook.com/v#{client.api_version}/#{ad_set_id}/ads",
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
      post: "https://graph.facebook.com/v#{client.api_version}/act_#{account_id}/ads",
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
    # [:ad_set_id]
    [:adset_id]
  end
end
