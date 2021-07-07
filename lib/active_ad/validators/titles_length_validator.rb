class TitlesLengthValidator < ActiveModel::EachValidator
  # def initialize(options = {})
  #   super
  #   options[:class].attr_accessor :maximums
  # end

  def validate_each(record, _attribute, value)
    value.each_with_index do |title, i|
      maximum = options[:maximums][i] || options[:maximums][0]
      record.errors.add(:titles, "title at index #{i} is too long (maximum is #{maximum} characters)") if title.length > maximum
    end
  end
end
