class ActiveAd::Facebook::Permission < ActiveAd::Facebook::Base
  # References:
  # - [https://developers.facebook.com/docs/graph-api/reference/user/permissions/]
  # - [https://developers.facebook.com/docs/graph-api/reference/user/]
  belongs_to :user

  # Use aliases to map external API attributes to the ActiveAd object attributes. We especially want to make sure identitfication attributes end with an '_id'
  # suffix. For example 'platform_attribute' should be aliased as 'platform_attribute_id'. This way when we call 'object.platform_attribute_id' we know we're
  # getting back an ID instead of an object.
  #
  # alias_attribute :platform_attribute, :active_ad_attribute

  # ActiveAd object attributes.
  attribute :permission, :string
  attribute :status, :string
  attribute :user_id, :big_integer

  # Use callbacks to execute code that should happen before or after `find`, `create`, `update`, `save`, `destroy`, `link` or `unlink`.
  #
  # before_save :do_something
  # after_destroy :do_something

  class << self
    def index_request(client:, **kwargs)
      params = kwargs.dup
      id, id_key = index_request_id_and_key(params)
      id = "act_#{id}" if id_key == :account_id

      {
        get: "#{client.base_url}/#{id}/permissions",
        params: params.merge(access_token: client.access_token)
      }
    end
  end

  def read_request
    raise ActiveAd::RequestError, 'Cannot read a permission'
  end

  def create_request
    raise ActiveAd::RequestError, 'Cannot create a permission'
  end

  def update_request
    raise ActiveAd::RequestError, 'Cannot update a permission'
  end

  def delete_request
    {
      delete: "#{client.base_url}/#{id}/permissions/#{permission}",
      params: { access_token: client.access_token }
    }
  end
end
