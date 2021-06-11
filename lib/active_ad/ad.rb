class ActiveAd::Ad < ActiveAd::Base
  attr_reader :ad_group

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
end
