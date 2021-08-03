class ActiveAd::Client
  extend ActiveModel::Callbacks
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveAd::Requestable

  attr_reader :response

  attribute :access_token, :string

  validates_presence_of :access_token

  define_model_callbacks :login

  after_login :set_access_token

  delegate :platform, to: :class

  # Returns the API version.
  #
  #   class Client
  #     api_version '1.0'
  #   end
  #
  #   Client.api_version # => '1.0'
  class_attribute :api_version, instance_reader: true, instance_writer: false

  # Returns the pagination strategy. Can be one of `:offset`, `:cursor` or `:relay_cursor`.
  #
  #   class Client
  #     pagination_type :cursor
  #   end
  #
  #   Client.pagination_type # => :cursor
  class_attribute :pagination_type, instance_reader: true, instance_writer: false

  class << self
    def platform
      to_s.split('::')[1].underscore
    end

    def api_version(version)
      self.api_version = version.to_s
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

  def login_request
    raise NotImplementedError, 'Subclasses must implement a login_request method'
  end

  private

  def set_access_token
    raise NotImplementedError, 'Subclasses must implement a private set_access_token method'
  end
end
