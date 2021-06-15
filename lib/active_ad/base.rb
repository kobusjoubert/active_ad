class ActiveAd::Base
  extend ActiveModel::Callbacks
  include ActiveModel::Validations

  attr_reader :response

  define_model_callbacks :find, :save, :update, :destroy

  # before_save :do_something
  # after_destroy :do_something

  def initialize(**kwargs)
    kwargs.each do |key, value|
      public_send("#{key}=", value)
    end
  end

  class << self
    # Returns object or nil.
    def find(**kwargs)
      object = new(**kwargs).send(:find)
      object.response.success? ? object : nil
    end

    # Returns object or exception.
    def find!(**kwargs)
      new(**kwargs).send(:find!)
    end

    # TODO: Might need some work to fullfil blank object when not created.
    # Returns object or blank object.
    def create(**kwargs)
      object = new(**kwargs)
      object.save
      object
    end

    # Returns object or exception.
    def create!(**kwargs)
      object = new(**kwargs)
      object.save!
      object
    end
  end

  # Returns true or false.
  def save
    @response = nil
    run_callbacks(:save) { @response = create_request }
    response.success?
  end

  # Returns true or exception.
  # ActiveAd::RecordInvalid (Validation failed: Client can't be blank).
  # ActiveAd::RecordInvalid (404 Not Found: {}).
  def save!
    save
    raise ActiveAd::RecordInvalid, errors.full_messages.join(', ') unless valid?
    raise ActiveAd::RecordInvalid, "#{response.status} #{response.reason_phrase}: #{response.body}" unless response.success?

    response.success?
  end

  # Returns true or false.
  def update # TODO: update(**kwargs)
    @response = nil
    run_callbacks(:update) { @response = update_request }
    response.sucess?
  end

  # Returns true or exception.
  def update! # TODO: update!(**kwargs)
    update
    # TODO: Raise errors
  end

  # Returns true or false.
  def destroy
    @response = nil
    run_callbacks(:destroy) { @response = delete_request }
    response.sucess?
  end

  # Returns true or exception.
  def destroy!
    destroy
    # TODO: Raise errors
  end

  private

  # Returns object or nil.
  def find
    @response = nil
    run_callbacks(:find) { @response = find_request }
    self
  end

  # Returns object or exception.
  # ActiveAd::RecordNotFound (Couldn't find record with 'id'=#{id}).
  # ActiveAd::RecordNotFound (404 Not Found: {}).
  def find!
    find
    # raise ActiveAd::RecordNotFound, "Couldn't find record with 'id'=#{id}" unless response.success? # TODO: Probably not what I want.
    raise ActiveAd::RecordNotFound, "#{response.status} #{response.reason_phrase}: #{response.body}" unless response.success?

    self
  end

  def find_request
    raise NotImplementedError, 'Subclasses must implement a find_request method'
  end

  def create_request
    raise NotImplementedError, 'Subclasses must implement a create_request method'
  end

  def update_request
    raise NotImplementedError, 'Subclasses must implement a update_request method'
  end

  def delete_request
    raise NotImplementedError, 'Subclasses must implement a delete_request method'
  end
end
