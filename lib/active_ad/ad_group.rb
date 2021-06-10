class ActiveAd::AdGroup
  attr_reader :campaign, :platform_object

  delegate :platform, to: :campaign

  def initialize(campaign:, **kwargs)
    @campaign = campaign
    @platform_object = "ActiveAd::#{platform.classify}::AdGroup".constantize.new(campaign: campaign, **kwargs)
  end

  class << self
    def create(campaign:, **kwargs)
      new(campaign: campaign, **kwargs).save
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
