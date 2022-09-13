class ActiveAd::Facebook::SavedAudience < ActiveAd::Base
  # References:
  # - [https://developers.facebook.com/docs/marketing-api/reference/saved-audience/]
  # - [https://developers.facebook.com/docs/marketing-api/audiences/overview/]
  READ_FIELDS = %i[
    id account approximate_count approximate_count_64bit delete_time description extra_info name operation_status permission_for_actions run_status
    sentence_lines targeting time_created time_updated
  ].freeze

  RUN_STATUS = %w[ACTIVE EXPIRING DELETED].freeze # TODO: Confirm that these are correct.

  belongs_to :account

  # Use aliases to map external API attributes to the ActiveAd object attributes. We especially want to make sure identitfication attributes end with an '_id'
  # suffix. For example 'platform_attribute' should be aliased as 'platform_attribute_id'. This way when we call 'object.platform_attribute_id' we know we're
  # getting back an ID instead of an object.
  #
  # alias_attribute :platform_attribute, :active_ad_attribute
  alias_attribute :time_created, :created_at
  alias_attribute :time_updated, :updated_at

  # ActiveAd object attributes.
  attribute :id, :big_integer
  attribute :account
  attribute :account_id, :big_integer
  attribute :approximate_count, :integer
  attribute :approximate_count_64bit, :big_integer
  attribute :delete_time, :integer
  attribute :description, :string
  attribute :extra_info, :string
  attribute :name, :string
  attribute :operation_status
  attribute :permission_for_actions
  attribute :run_status, :string
  attribute :sentence_lines, array: true
  attribute :targeting
  attribute :created_at, :datetime
  attribute :updated_at, :datetime

  # Use validations which will overwrite the parent class implementations.
  #
  # validates_length_of :title, maximum: 24
  # validates :titles, titles_length: { maximums: [24, 50] }

  # Use callbacks to execute code that should happen before or after `find`, `create`, `update`, `save`, `destroy`, `link` or `unlink`.
  #
  # before_save :do_something
  # after_destroy :do_something
  after_find :set_account_id

  class << self
    def index_request(client:, **kwargs)
      params = kwargs.dup
      id, id_key = index_request_id_and_key(params)
      id = "act_#{id}" if id_key == :account_id
      fields = ((params.delete(:fields) || READ_FIELDS) + relational_attributes).uniq

      {
        get: "#{client.base_url}/#{id}/saved_audiences",
        params: params.merge(access_token: client.access_token, fields: fields.join(','))
      }
    end

    # Attributes to be requested from the external API which are required by `belongs_to` to work.
    def relational_attributes
      %i[account]
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
    raise ActiveAd::RequestError, 'Cannot create a saved audience'
  end

  def update_request
    raise ActiveAd::RequestError, 'Cannot update a saved audience'
  end

  def delete_request
    raise ActiveAd::RequestError, 'Cannot delete a saved audience'
  end

  private

  def set_account_id
    assign_attributes(account_id: attributes.dig('account', 'account_id'))
  end
end
