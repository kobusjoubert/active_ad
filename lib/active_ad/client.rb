class ActiveAd::Client
  extend ActiveModel::Callbacks
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveAd::Requestable
  include ActiveAd::Validationable

  attr_reader :response

  attribute :access_token, :string

  validates_presence_of :access_token

  define_model_callbacks :login, :refresh_token

  after_login :set_access_token
  after_refresh_token :set_access_token

  delegate :platform, :platform_class, to: :class

  # Returns the API version.
  #
  #   class Client
  #     api_version '1.0'
  #   end
  #
  #   Client.api_version # => '1.0'
  class_attribute :api_version, instance_reader: true, instance_writer: false

  # Returns the API version.
  #
  #   class Client
  #     base_url 'https://platform/v1.0'
  #   end
  #
  #   Client.base_url # => 'https://platform/v1.0'
  class_attribute :base_url, instance_reader: true, instance_writer: false

  # Returns the pagination strategy. Can be one of `:offset`, `:cursor` or `:relay_cursor`.
  #
  #   class Client
  #     pagination_type :cursor
  #   end
  #
  #   Client.pagination_type # => :cursor
  class_attribute :pagination_type, instance_reader: true, instance_writer: false

  class << self
    # Returns a symobol in underscore style: `:platform_name`.
    def platform
      platform_class.underscore.to_sym
    end

    # Returns a string in classify style: `"PlatformClassName"`.
    def platform_class
      to_s.split('::')[1]
    end

    def api_version(version)
      self.api_version = version.to_s
    end

    def base_url(url)
      self.base_url = url
    end

    def pagination_type(type)
      self.pagination_type = type.to_sym
    end
  end

  # Returns true or false.
  def login
    @response = nil

    run_callbacks(:login) do
      ActiveAd.logger.debug("Calling login_request with attributes: #{ActiveAd.parameter_filter.filter(attributes)}")
      @response = request(login_request)
    end

    response.success?
  end

  # Returns true or exception.
  #
  #   ActiveAd::LoginError ({})
  def login!
    login
    raise ActiveAd::LoginError, response.body unless response.success?

    response.success?
  end

  # Returns true or false.
  def refresh_token
    @response = nil

    run_callbacks(:refresh_token) do
      ActiveAd.logger.debug("Calling refresh_token_request with attributes: #{ActiveAd.parameter_filter.filter(attributes)}")
      @response = request(refresh_token_request)
    end

    response.success?
  end

  # Returns true or exception.
  #
  #   ActiveAd::LoginError ({})
  def refresh_token!
    refresh_token
    raise ActiveAd::LoginError, response.body unless response.success?

    response.success?
  end

  def login_request
    raise NotImplementedError, 'Subclasses must implement a login_request method'
  end

  def refresh_token_request
    raise NotImplementedError, 'Subclasses must implement a refresh_request method'
  end

  # TODO: This is needed for Facebook to retrieve the user's pages. If this does not work the same for Google, Twitter etc, move this method to
  # ActiveAd::Facebook::Client instead.
  def user
    raise NotImplementedError, 'Subclasses must implement a user method'
  end

  private

  def set_access_token
    raise NotImplementedError, 'Subclasses must implement a private set_access_token method'
  end
end
