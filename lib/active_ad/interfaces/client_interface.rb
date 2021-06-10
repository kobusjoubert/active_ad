class ActiveAd::ClientInterface
  def login
    raise NotImplementedError
  end

  def platform
    @_platform ||= self.class.to_s.split('::')[1].underscore
  end
end
