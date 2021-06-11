class ActiveAd::Campaign < ActiveAd::Base
  attr_reader :account

  delegate :platform, to: :account

  def initialize(account:, **kwargs)
    @account = account
    @platform_object = "ActiveAd::#{platform.classify}::Campaign".constantize.new(account: account, **kwargs)
  end

  class << self
    def create(account:, **kwargs)
      new(account: account, **kwargs).save
    end
  end
end
