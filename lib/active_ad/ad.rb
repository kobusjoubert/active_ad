class ActiveAd::Ad < ActiveAd::Base
  attr_accessor :ad_group, :type, :name, :title, :titles, :description, :descriptions

  delegate :platform, :api_version, :access_token, to: :ad_group

  validates_presence_of :ad_group
  validates_presence_of :title_or_titles
  validates_length_of :title, maximum: 255, unless: :platform_checks_length_of_title, allow_blank: true
  validates :titles, titles_length: { maximums: [255] }, unless: :platform_checks_length_of_titles, allow_blank: true

  # before_save :do_something
  # after_destroy :do_something

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
