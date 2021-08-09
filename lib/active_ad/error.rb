module ActiveAd
  class Error < StandardError; end

  class RequestError < Error; end

  class ResponseError < Error; end

  class RecordInvalid < Error; end

  class RecordNotDeleted < Error; end

  class RecordNotFound < Error; end

  class RecordNotLinked < Error; end

  class RecordNotUnlinked < Error; end

  class LoginError < Error; end
end
