class ActiveAd::Campaign
  attr_reader :account, :platform_object

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
