module ActiveAd
  class Error < StandardError; end

  class RequestError < Error; end

  class ResponseError < Error; end
end
