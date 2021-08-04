# Helper methods for custom validation messages.
module ActiveAd::Validationable
  extend ActiveSupport::Concern

  class_methods do
    def validates_inclusion_of_message(list)
      "%{value} is not included in the list: #{list.join(', ')}"
    end
  end
end
