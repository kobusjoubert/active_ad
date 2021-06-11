module ActiveAd
  class Error < StandardError; end

  class RequestError < Error; end

  class ResponseError < Error; end

  class LoginError < Error; end
end
