class ActiveAd::Account < ActiveAd::Base
  attr_reader :client

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
end
