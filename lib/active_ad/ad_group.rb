class ActiveAd::AdGroup < ActiveAd::Base
  attr_reader :campaign

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
end
