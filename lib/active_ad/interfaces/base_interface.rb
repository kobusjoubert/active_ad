class ActiveAd::BaseInterface
  extend ActiveModel::Callbacks
  include ActiveModel::Validations

  attr_reader :request, :response

  define_model_callbacks :save, :update, :destroy

  # before_save :do_something
  # after_destroy :do_something

  def initialize(**kwargs)
    kwargs.each do |key, value|
      send("#{key}=", value)
    end
  end

  def save
    @request = nil
    @response = nil

    run_callbacks(:save) do
      @request = create_request
      @response = JSON.parse(request.body).with_indifferent_access
    end

    self
  end

  def update
    @request = nil
    @response = nil

    run_callbacks(:update) do
      @request = update_request
      @response = JSON.parse(request.body).with_indifferent_access
    end

    self
  end

  def destroy
    @request = nil
    @response = nil

    run_callbacks(:destroy) do
      @request = delete_request
      @response = JSON.parse(request.body).with_indifferent_access
    end

    self
  end

  def create_request
    raise NotImplementedError, 'Subclasses must implement a public create_request method'
  end

  def update_request
    raise NotImplementedError, 'Subclasses must implement a public update_request method'
  end

  def delete_request
    raise NotImplementedError, 'Subclasses must implement a public delete_request method'
  end
end
