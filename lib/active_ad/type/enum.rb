class ActiveAd::Type::Enum < ActiveModel::Type::Value
  def type
    :enum
  end

  private

  def cast_value(value)
    value.to_s
  end
end
