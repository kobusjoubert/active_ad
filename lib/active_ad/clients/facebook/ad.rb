class ActiveAd::Facebook::Ad < ActiveAd::Base
  # Attributes that clashes with the relational methods.
  #
  #   'adset'
  READ_FIELDS = %i[
    id account_id ad_review_feedback adlabels adset_id bid_amount campaign campaign_id configured_status conversion_domain created_time creative
    effective_status issues_info last_updated_by_app_id name preview_shareable_link recommendations source_ad source_ad_id status tracking_specs updated_time
  ].freeze
  # account_id ad_review_feedback adlabels adset_id bid_amount campaign_id configured_status conversion_domain created_time effective_status issues_info
  # last_updated_by_app_id name preview_shareable_link recommendations source_ad_id status tracking_specs updated_time

  belongs_to :ad_set
  has_many :ad_creatives

  # Use aliases to map external API attributes to the ActiveAd object attributes. We especially want to make sure identitfication attributes end with an '_id'
  # suffix. For example 'platform_attribute' should be aliased as 'platform_attribute_id'. This way when we call 'object.platform_attribute_id' we know we're
  # getting back an ID instead of an object.
  #
  # alias_attribute :platform_attribute, :active_ad_attribute
  alias_attribute :adlabels, :ad_labels
  # alias_attribute :adset, :ad_set # Clashes with the `belongs_to :campaign` relationship.
  alias_attribute :adset_id, :ad_set_id
  alias_attribute :created_time, :created_at
  alias_attribute :updated_time, :updated_at

  # ActiveAd object attributes.
  attribute :account_id, :big_integer
  attribute :ad_review_feedback
  attribute :ad_labels, array: true
  # attribute :ad_set # Clashes with the `belongs_to :campaign` relationship.
  attribute :ad_set_id, :big_integer
  attribute :bid_amount, :integer
  attribute :campaign
  attribute :campaign_id, :big_integer
  attribute :configured_status, :string
  attribute :conversion_domain, :string
  attribute :created_at, :datetime
  attribute :creative
  attribute :effective_status, :string
  attribute :issues_info, array: true
  attribute :last_updated_by_app_id, :big_integer # TODO: The Facebook type is `id`?
  attribute :name, :string
  attribute :preview_shareable_link, :string
  attribute :recommendations, array: true
  attribute :source_ad
  attribute :source_ad_id, :big_integer
  attribute :status, :string # , default: 'PAUSED'
  attribute :tracking_specs, array: true
  attribute :updated_at, :datetime

  # Use validations which will overwrite the parent class implementations.
  #
  # validates_length_of :title, maximum: 24
  # validates :titles, titles_length: { maximums: [24, 50] }
  validates_presence_of :name, :status, on: :create

  # Use validations which will overwrite the parent class implementations.
  #
  # validates :titles, titles_length: { maximums: [24, 50] }
  validates_length_of :title, maximum: 24

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
    [:adset_id]
  end
end
