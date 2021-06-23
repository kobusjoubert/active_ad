class ActiveAd::Base
  extend ActiveModel::Callbacks
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Dirty

  attr_reader :response

  define_model_callbacks :find, :save, :create, :update, :destroy

  delegate :platform, :api_version, :access_token, to: :client

  # before_save :do_something
  # after_destroy :do_something

  # This exception happens when using `include ActiveModel::Attributes`.
  #
  #   Traceback (most recent call last):
  #           7: from bin/console:14:in `<main>'
  #           6: from (irb):92:in `<main>'
  #           5: from (irb):93:in `rescue in <main>'
  #           4: from /Users/kobus/Development/ClickAds/active_ad/lib/active_ad/base.rb:45:in `create!'
  #           3: from /Users/kobus/Development/ClickAds/active_ad/lib/active_ad/base.rb:45:in `new'
  #           2: from /Users/kobus/.rbenv/versions/3.0.0/lib/ruby/gems/3.0.0/gems/activemodel-6.1.3.2/lib/active_model/attributes.rb:77:in `initialize'
  #           1: from /Users/kobus/Development/ClickAds/active_ad/lib/active_ad/base.rb:12:in `initialize'
  #   ArgumentError (wrong number of arguments (given 1, expected 0))
  #
  # def initialize(**kwargs)
  #   super(**kwargs)
  #
  #   # By including ActiveModel::Model and calling super, attributes will be assigned with `assign_attributes(kwargs)` which calls
  #   # `public_send("#{key}=", value)` internally.
  #   #
  #   # kwargs.each do |key, value|
  #   #   public_send("#{key}=", value)
  #   # end
  # end

  def initialize(**kwargs)
    super

    # Allows us to initialize a known record without needing to call `.find('id')` first.
    @new_record = kwargs[:id].blank?
  end

  class << self
    # TODO: Thread safety?
    def client
      "ActiveAd::#{descendants.last.to_s.split('::')[1]}::Connection".constantize.client
    end

    # Returns object or nil.
    def find(id, **kwargs)
      object = new(id: id, **kwargs).send(:find)
      object.response.success? ? object : nil
    end

    # Returns object or exception.
    def find!(id, **kwargs)
      new(id: id, **kwargs).send(:find!)
    end

    # Returns object or blank object.
    # TODO: Might need some work to fullfil blank object when not created.
    def create(**kwargs)
      object = new(**kwargs.except(:validate))
      object.save(**kwargs)
      object
    end

    # Returns object or exception.
    def create!(**kwargs)
      object = new(**kwargs.except(:validate))
      object.save!(**kwargs)
      object
    end
  end

  def client
    ActiveAd::Base.client
  end

  # Returns true or false.
  def save(**kwargs)
    @response = nil

    run_callbacks(:save) do
      if new_record?
        run_callbacks(:create) do
          return false unless perform_validations(kwargs)

          @response = create_request
        end
      else
        run_callbacks(:update) do
          return false unless changed?
          return false unless perform_validations(kwargs)

          @response = update_request
        end
      end
    end

    response.success?
  end

  # Returns true or exception.
  #
  #   ActiveAd::RecordInvalid (Validation failed: Client can't be blank).
  #   ActiveAd::RecordInvalid (404 Not Found: {}).
  def save!(**kwargs)
    save(**kwargs)
    raise ActiveAd::RecordInvalid, errors.full_messages.join(', ') if errors.any?
    raise ActiveAd::RecordInvalid, "#{response.status} #{response.reason_phrase}: #{response.body}" unless response.success?
    response.success?
  end

  # Returns true or false.
  def update(**kwargs)
    set_attributes(kwargs)
    save(**kwargs)
  end

  # Returns true or exception.
  def update!(**kwargs)
    set_attributes(kwargs)
    save!(**kwargs)
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

  def new_record?
    @new_record
  end

  # Borrowed some methods from ActiveRecord::Validations (งツ)ว
  def valid?(context = nil)
    context ||= default_validation_context
    output = super(context)
    errors.empty? && output
  end

  alias_method :validate, :valid?

  private

  def perform_validations(options = {})
    options[:validate] == false || valid?
  end

  def default_validation_context
    new_record? ? :create : :update
  end

  def set_attributes(attributes = {})
    attributes.each do |attribute, value|
      next if ['id', 'validate'].include?(attribute) # Attributes we don't need for create or update. We set `id` on initialize.

      attributes =
        if self.class.const_defined?('ATTRIBUTES_MAPPING')
          { (self.class::ATTRIBUTES_MAPPING[attribute.to_sym] || attribute) => value }
        else
          { attribute => value }
        end

      assign_attributes(attributes) # TODO: Try attributes = attributes
    rescue  ActiveModel::UnknownAttributeError
    end
  end

  # Returns object or nil.
  def find
    @response = nil
    run_callbacks(:find) { @response = read_request }

    if response.success?
      set_attributes(response.body)
      clear_changes_information
    end

    self
  end

  # Returns object or exception.
  #
  #   ActiveAd::RecordNotFound (Couldn't find record with 'id'=#{id}).
  #   ActiveAd::RecordNotFound (404 Not Found: {}).
  def find!
    find
    # raise ActiveAd::RecordNotFound, "Couldn't find record with 'id'=#{id}" unless response.success? # TODO: Probably not what I want.
    raise ActiveAd::RecordNotFound, "#{response.status} #{response.reason_phrase}: #{response.body}" unless response.success?

    self
  end

  def create_request_attributes
    attributes.compact
  end

  def update_request_attributes
    changes.transform_values { |value| value.last }.except(:id)
  end

  # Exchange attribute keys to map what the external API expects.
  #
  #   attributes         => { "name" => "My Campaign", "status" => "PAUSED" }
  #   attributes_swapped => { "name" => "My Campaign", "effective_status" => "PAUSED" }
  def attributes_swapped
    return attributes unless self.class.const_defined?('ATTRIBUTES_MAPPING')

    # ATTRIBUTES_MAPPING.invert to swap the keys and values.
    attributes.deep_transform_keys do |key|
      self.class::ATTRIBUTES_MAPPING.values.include?(key.to_sym) ? self.class::ATTRIBUTES_MAPPING.key(key.to_sym).to_s : key
    end
  end

  # Exchange keys to map what the external API expects.
  #
  #   ['name', 'status'] => ['name', 'effective_status']
  #   ['name', 'effective_status'] => ['name', 'effective_status']
  def keys_for_request(keys)
    return keys unless self.class.const_defined?('ATTRIBUTES_MAPPING')

    keys.map { |key| (self.class::ATTRIBUTES_MAPPING.invert.stringify_keys[key] || key).to_s }
  end

  # Exchange keys to map what the internal API expects.
  #
  #   ['name', 'status'] => ['name', 'status']
  #   ['name', 'effective_status'] => ['name', 'status']
  def keys_for_object(keys)
    return keys unless self.class.const_defined?('ATTRIBUTES_MAPPING')

    keys.map { |key| (self.class::ATTRIBUTES_MAPPING.stringify_keys[key] || key).to_s }
  end

  def read_request
    raise NotImplementedError, 'Subclasses must implement a read_request method'
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
