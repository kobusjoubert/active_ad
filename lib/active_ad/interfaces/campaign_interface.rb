class ActiveAd::CampaignInterface
  extend ActiveModel::Callbacks
  include ActiveModel::Validations

  attr_accessor :account, :response, :name

  validates_presence_of :account

  define_model_callbacks :save, :update, :destroy

  # before_save :do_something
  # after_destroy :do_something

  def initialize(**kwargs)
    kwargs.each do |key, value|
      send("#{key}=", value)
    end
  end

  def save
    self.response = nil

    run_callbacks(:save) do
      self.response = create_request
    end

    self
  end

  def update
    self.response = nil

    run_callbacks(:update) do
      self.response = update_request
    end

    self
  end

  def destroy
    self.response = nil

    run_callbacks(:destroy) do
      self.response = delete_request
    end

    self
  end

  def create_request
    raise NotImplementedError
  end

  def update_request
    raise NotImplementedError
  end

  def delete_request
    raise NotImplementedError
  end
end
