class ActiveAd::Account
  attr_reader :client, :platform_object

  delegate :platform, to: :client

  def initialize(client:, **kwargs)
    @client = client
    @platform_object = "ActiveAd::#{platform.classify}::Account".constantize.new(client: client, **kwargs)
  end

  class << self
    def create(client:, **kwargs)
      new(client: client, **kwargs).save
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
