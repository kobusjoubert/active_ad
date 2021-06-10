class ActiveAd::AdInterface
  extend ActiveModel::Callbacks
  include ActiveModel::Validations

  attr_accessor :ad_group, :response, :type, :name, :title, :titles, :description, :descriptions

  validates_presence_of :ad_group
  validates_presence_of :title_or_titles
  validates_length_of :title, maximum: 255, unless: :platform_checks_length_of_title, allow_blank: true
  validates :titles, titles_length: { maximums: [255] }, unless: :platform_checks_length_of_titles, allow_blank: true

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

  private

  def title_or_titles
    title || titles
  end

  def platform_checks_length_of_title
    _validators[:title].each do |validator|
      return true if validator.instance_of?(ActiveModel::Validations::LengthValidator) && validator.options[:unless] != :platform_checks_length_of_title
    end

    false
  end

  def platform_checks_length_of_titles
    _validators[:titles].each do |validator|
      # TODO: TitlesLengthValidator -> ActiveModel::Validations::TitlesLengthValidator
      return true if validator.instance_of?(TitlesLengthValidator) && validator.options[:unless] != :platform_checks_length_of_titles
    end

    false
  end
end
