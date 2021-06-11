class ActiveAd::Base
  attr_reader :platform_object

  def save
    platform_object.save
  end

  def update
    platform_object.update
  end

  def destroy
    platform_object.destroy
  end

  def method_missing(method_name, *args, **kwargs, &block)
    if platform_object.respond_to?(method_name)
      platform_object.send(method_name, *args, **kwargs, &block)
    else
      super
    end
  end
end
