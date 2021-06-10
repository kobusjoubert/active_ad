class ActiveAd::Ad
  attr_reader :ad_group, :platform_object

  delegate :platform, to: :ad_group

  def initialize(ad_group:, **kwargs)
    @ad_group = ad_group
    @platform_object = "ActiveAd::#{platform.classify}::Ad".constantize.new(ad_group: ad_group, **kwargs)
  end

  class << self
    def create(ad_group:, **kwargs)
      new(ad_group: ad_group, **kwargs).save
    end
  end

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
