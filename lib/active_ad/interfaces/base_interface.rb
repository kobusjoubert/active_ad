class ActiveAd::BaseInterface
  extend ActiveModel::Callbacks
  include ActiveModel::Validations

  attr_reader :response

  define_model_callbacks :save, :update, :destroy

  # before_save :do_something
  # after_destroy :do_something

  def initialize(**kwargs)
    kwargs.each do |key, value|
      send("#{key}=", value)
    end
  end

  def save
    @response = nil

    run_callbacks(:save) do
      @response = create_request
    end

    self
  end

  def update
    @response = nil

    run_callbacks(:update) do
      @response = update_request
    end

    self
  end

  def destroy
    @response = nil

    run_callbacks(:destroy) do
      @response = delete_request
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
