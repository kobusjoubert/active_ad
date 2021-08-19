module ActiveAd
  class Error < StandardError; end

  class RequestError < Error; end

  class ResponseError < Error; end

  class RecordInvalid < Error
    attr_reader :record

    def initialize(record = nil)
      @record = record
      message = record ? record.errors.full_messages.join(', ') : 'Record invalid'
      super(message)
    end
  end

  class RecordNotSaved < Error
    attr_reader :record, :response

    def initialize(record = nil, response = nil)
      @record = record
      @response = response
      message = response ? "#{response.status} #{response.reason_phrase}: #{response.body}" : 'Failed to save the record'
      super(message)
    end
  end

  class RecordNotDeleted < Error
    attr_reader :record, :response

    def initialize(record = nil, response = nil)
      @record = record
      @response = response
      message = response ? "#{response.status} #{response.reason_phrase}: #{response.body}" : 'Failed to delete the record'
      super(message)
    end
  end

  class RecordNotFound < Error
    attr_reader :record, :response

    def initialize(record = nil, response = nil)
      @record = record
      @response = response
      message = response ? "#{response.status} #{response.reason_phrase}: #{response.body}" : 'Failed to find the record'
      super(message)
    end
  end

  class RecordNotLinked < Error
    attr_reader :record, :response

    def initialize(record = nil, response = nil)
      @record = record
      @response = response
      message = response ? "#{response.status} #{response.reason_phrase}: #{response.body}" : 'Failed to link the record'
      super(message)
    end
  end

  class RecordNotUnlinked < Error
    attr_reader :record, :response

    def initialize(record = nil, response = nil)
      @record = record
      @response = response
      message = response ? "#{response.status} #{response.reason_phrase}: #{response.body}" : 'Failed to unlink the record'
      super(message)
    end
  end

  class LoginError < Error; end
end
