class ActiveAd::Facebook::Pixel < ActiveAd::Base
  # References:
  # - [https://developers.facebook.com/docs/marketing-api/reference/ads-pixel/]
  # - [https://developers.facebook.com/docs/marketing-api/reference/ad-account/adspixels/]
  #
  # Requesting the following fields causes status `400` error with messages.
  #
  #   'creator' => "(#10) To use ads_management, your use of this endpoint must be reviewed and approved by Facebook. To submit this permission for review
  #                 please read our documentation on reviewable permissions: https://developers.facebook.com/docs/apps/review"
  READ_FIELDS = %i[
    id automatic_matching_fields can_proxy code creation_time data_use_setting enable_automatic_matching first_party_cookie_status is_created_by_business is_crm
    is_unavailable last_fired_time name owner_ad_account owner_business
  ].freeze

  UNLINK_REQUEST_MAPPING = {
    account_id: { path: 'shared_accounts', param: :account_id },
    business_id: { path: 'shared_accounts', param: :business }
  }.freeze

  DATA_USE_SETTINGS = %w[EMPTY ADVERTISING_AND_ANALYTICS ANALYTICS_ONLY].freeze
  FIRST_PARTY_COOKIE_STATUS = %w[EMPTY FIRST_PARTY_COOKIE_ENABLED FIRST_PARTY_COOKIE_DISABLED].freeze

  private_constant :UNLINK_REQUEST_MAPPING

  belongs_to :account
  belongs_to :business

  # Use aliases to map external API attributes to the ActiveAd object attributes. We especially want to make sure identitfication attributes end with an '_id'
  # suffix. For example 'platform_attribute' should be aliased as 'platform_attribute_id'. This way when we call 'object.platform_attribute_id' we know we're
  # getting back an ID instead of an object.
  #
  # alias_attribute :platform_attribute, :active_ad_attribute
  alias_attribute :creation_time, :created_at
  alias_attribute :last_fired_time, :last_fired_at

  # ActiveAd object attributes.
  attribute :id, :big_integer
  attribute :account_id, :big_integer
  attribute :automatic_matching_fields, array: true
  attribute :business_id, :big_integer
  attribute :can_proxy, :boolean
  attribute :code, :string
  attribute :created_at, :datetime
  attribute :creator
  attribute :data_use_setting, :string
  attribute :enable_automatic_matching, :boolean
  attribute :first_party_cookie_status, :string
  attribute :is_created_by_business, :boolean
  attribute :is_crm, :boolean
  attribute :is_unavailable, :boolean
  attribute :last_fired_at, :datetime
  attribute :name, :string
  attribute :owner_ad_account
  attribute :owner_business
  attribute :server_events_business_ids, array: true

  # Use validations which will overwrite the parent class implementations.
  #
  # validates_length_of :title, maximum: 24
  # validates :titles, titles_length: { maximums: [24, 50] }
  validates_presence_of :name, on: :create

  # The only endpoint which went and downcased the enums ¯\(°_o)/¯
  validates_inclusion_of :data_use_setting, in: DATA_USE_SETTINGS + DATA_USE_SETTINGS.map(&:downcase),
                                            allow_blank: true,
                                            message: validates_inclusion_of_message(DATA_USE_SETTINGS)
  validates_inclusion_of :first_party_cookie_status, in: FIRST_PARTY_COOKIE_STATUS + FIRST_PARTY_COOKIE_STATUS.map(&:downcase),
                                                     allow_blank: true,
                                                     message: validates_inclusion_of_message(FIRST_PARTY_COOKIE_STATUS)

  # Use callbacks to execute code that should happen before or after `find`, `create`, `update`, `save`, `destroy`, `link` or `unlink`.
  #
  # before_save :do_something
  # after_destroy :do_something
  after_find :set_account_id, :set_business_id

  class << self
    def index_request(**kwargs)
      params = kwargs.dup
      id, id_key = index_request_id_and_key(params)
      id = "act_#{id}" if id_key == :account_id
      fields = params.delete(:fields) || READ_FIELDS

      {
        get: "#{client.base_url}/#{id}/adspixels",
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

  def create_request
    {
      post: "#{client.base_url}/act_#{account_id}/adspixels",
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
    raise ActiveAd::RequestError, 'Cannot delete a pixel'
  end

  # Request examples.
  #
  #   pixel.unlink(account_id: '1')
  #   pixel.unlink(business_id: '1')
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

  def create_request_attributes
    super.except('account_id') # Using `account_id` in the request url only.
  end

  def create_response_id(response)
    response.body['id']
  end

  # Attributes to be requested from the external API which are required by `belongs_to` to work.
  def relational_attributes
    %i[owner_ad_account owner_business]
  end

  def set_account_id
    assign_attributes(account_id: response.body.dig('owner_ad_account', 'account_id')) if response.success?
  end

  def set_business_id
    assign_attributes(business_id: response.body.dig('owner_business', 'id')) if response.success?
  end
end
