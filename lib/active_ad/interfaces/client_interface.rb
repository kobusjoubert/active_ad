class ActiveAd::ClientInterface
  extend ActiveModel::Callbacks
  include ActiveModel::Validations

  attr_reader :platform, :request, :response, :access_token

  define_model_callbacks :login

  after_login :set_access_token

  def initialize(**kwargs)
    kwargs.each do |key, value|
      send("#{key}=", value)
    end

    @platform = self.class.to_s.split('::')[1].underscore
  end

  def login
    @request = nil
    @response = nil

    run_callbacks(:login) do
      @request = login_request
      @response = JSON.parse(request.body).with_indifferent_access
    end

    self
  end

  def login_request
    raise NotImplementedError, 'Subclasses must implement a login_request method'
  end

  private

  def set_access_token
    raise NotImplementedError, 'Subclasses must implement a private set_access_token method'
  end
end
