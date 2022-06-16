class ActiveAd::Base
  extend ActiveModel::Callbacks
  include ActiveModel::Model
  include ActiveModel::Attributes
  include ActiveModel::Dirty
  include ActiveAd::Requestable
  include ActiveAd::Validationable

  RESERVED_ATTRIBUTES = %i[validate stale].freeze

  attr_reader :response

  # Overwrite in child classes if the field is actually an :integer or :big_integer and not a :string.
  attribute :id, :string

  define_model_callbacks :find, :save, :create, :update, :destroy, :link, :unlink

  delegate :client, :entity, :entity_class, :platform, :platform_class, to: :class

  # before_save :do_something
  # after_destroy :do_something

  # This exception happens when using `include ActiveModel::Attributes`.
  #
  #   Traceback (most recent call last):
  #           7: from bin/console:14:in `<main>'
  #           6: from (irb):92:in `<main>'
  #           5: from (irb):93:in `rescue in <main>'
  #           4: from /Users/kobus/Development/active_ad/lib/active_ad/base.rb:45:in `create!'
  #           3: from /Users/kobus/Development/active_ad/lib/active_ad/base.rb:45:in `new'
  #           2: from /Users/kobus/.rbenv/versions/3.0.0/lib/ruby/gems/3.0.0/gems/activemodel-6.1.3.2/lib/active_model/attributes.rb:77:in `initialize'
  #           1: from /Users/kobus/Development/active_ad/lib/active_ad/base.rb:12:in `initialize'
  #   ArgumentError (wrong number of arguments (given 1, expected 0))
  #
  # def initialize(**kwargs)
  #   super
  #
  #   # By including ActiveModel::Model and calling super, attributes will be assigned with `assign_attributes(kwargs)` which calls
  #   # `public_send("#{key}=", value)` internally.
  #   #
  #   # kwargs.each do |key, value|
  #   #   public_send("#{key}=", value)
  #   # end
  # end

  # Returns a list of the associations defined by `belongs_to` on a class.
  #
  #   class Campaign
  #     belongs_to :account
  #   end
  #
  #   Campaign.belongs_to_relations # => [:account]
  class_attribute :belongs_to_relations, instance_accessor: false, default: []

  # Returns a list of the associations' identification fields defined by `belongs_to` on a class.
  #
  #   class Campaign
  #     belongs_to :account
  #   end
  #
  #   Campaign.belongs_to_relations_ids # => [:account_id]
  class_attribute :belongs_to_relations_ids, instance_accessor: false, default: []

  # Returns a list of the associations defined by `has_many` on a class.
  #
  #   class Campaign
  #     has_many :ad_groups
  #     has_many :ads
  #   end
  #
  #   Campaign.has_many_relations # => [:ad_groups, :ads]
  class_attribute :has_many_relations, instance_accessor: false, default: []

  # Returns a list of the associations' identification fields defined by `has_many` on a class.
  #
  #   class Campaign
  #     has_many :ad_groups
  #     has_many :ads
  #   end
  #
  #   AdGroup.has_many_relations_ids # => [:campaign_id]
  #   Ad.has_many_relations_ids      # => [:campaign_id]
  class_attribute :has_many_relations_ids, instance_accessor: false, default: []

  def initialize(**kwargs)
    super

    # Allows us to instantiate a known record using `.new(id: 'id', stale: true)` without needing a network request when calling `.find('id')`.
    @new_record = kwargs[:id].blank?
    clear_changes_information if kwargs[:stale].present?
  end

  class << self
    # TODO: Thread safety?
    def client
      "ActiveAd::#{platform_class}".constantize.client
    end

    # Returns a symobol in underscore style: `:entity_name`.
    def entity
      entity_class.underscore.to_sym
    end

    # Returns a string in classify style: `"EntityClassName"`.
    def entity_class
      (descendants.any? ? descendants.last : self).to_s.split('::')[2]
    end

    # Returns a symobol in underscore style: `:platform_name`.
    def platform
      platform_class.underscore.to_sym
    end

    # Returns a string in classify style: `"PlatformClassName"`.
    def platform_class
      (descendants.any? ? descendants.last : self).to_s.split('::')[1]
    end

    # Returns an ActiveAd::Relation object.
    def has_many(model_name)
      self.has_many_relations += [model_name]
      "ActiveAd::#{platform_class}::#{model_name.to_s.classify}".constantize.has_many_relations_ids += [:"#{entity}_id"]

      define_method(model_name) do |kwargs = {}|
        "ActiveAd::#{platform_class}::#{model_name.to_s.classify}".constantize.where("#{entity}_id".to_sym => id, **kwargs)
      end
    end

    # Returns an ActiveAd::Base object.
    def belongs_to(model_name)
      self.belongs_to_relations += [model_name]
      self.belongs_to_relations_ids += [:"#{model_name}_id"]
      method = ActiveAd.raise_relational_errors ? 'find!' : 'find'

      define_method(model_name) do |kwargs = {}|
        relation_id = public_send("#{model_name}_id")
        "ActiveAd::#{platform_class}::#{model_name.to_s.classify}".constantize.public_send(method, relation_id, **kwargs)
      end
    end

    alias_method :has_one, :belongs_to

    # Returns an ActiveAd::Relation object.
    def where(**kwargs)
      ActiveAd::Relation.new(self, **kwargs)
    end

    # Allows us to call `ActiveAd::Base.limit` without creating an `ActiveAd::Base.where` instance first.
    delegate :limit, to: :where

    # Allows us to call `ActiveAd::Base.offset` without creating an `ActiveAd::Base.where` instance first.
    delegate :offset, to: :where

    # Returns object or nil.
    def find(id, **kwargs)
      return nil if id.blank?

      object = new(id: id).send(:find, **kwargs)
      object.response.success? ? object : nil
    end

    # Returns object or exception.
    def find!(id, **kwargs)
      raise ArgumentError, 'missing keyword: :id' if id.blank?

      new(id: id).send(:find!, **kwargs)
    end

    # Returns object or blank object.
    def create(**kwargs)
      object = new(**kwargs)
      (object.save(**kwargs) && object) || new
    end

    # Returns object or exception.
    def create!(**kwargs)
      object = new(**kwargs)
      object.save!(**kwargs) && object
    end

    def index_request(**_kwargs)
      raise NotImplementedError, 'Subclasses must implement an index_request method'
    end

    # Mutates the params by removing the relational key injected by the `has_many` method.
    def index_request_id_and_key(params)
      id_keys = params.keys & has_many_relations_ids
      id_key = id_keys.last

      ActiveAd.logger.warn("Picking relation '#{id_key}' out of #{id_keys}. Might not be what you were looking for, provide only one key.") if id_keys.size > 1
      raise ArgumentError, "missing keyword: must include one of #{has_many_relations_ids}; received #{params}" unless (id = params.delete(id_key))

      [id, id_key]
    end
  end

  # Returns true or false.
  def save(**kwargs)
    @response = nil

    run_callbacks(:save) do
      if new_record?
        run_callbacks(:create) do
          return false unless perform_validations(kwargs) # Not validating kwargs here, only checking if we need to validate at all incase of `validate: false`.

          ActiveAd.logger.debug("Calling create_request with kwargs: #{kwargs}")
          @response = request(create_request)

          if response.success?
            @new_record = false
            clear_changes_information
            self.id = create_response_id(response)
          end
        end
      else
        run_callbacks(:update) do
          return false unless changed?
          return false unless perform_validations(kwargs) # Not validating kwargs here, only checking if we need to validate at all incase of `validate: false`.

          ActiveAd.logger.debug("Calling update_request with id: #{id}; kwargs: #{kwargs}")
          @response = request(update_request)
          clear_changes_information if response.success?
        end
      end
    end

    # If an `:abort` was thrown by a `before_` callback or an `ActiveAd::RecordNotSaved` exception has been raised, there will be no response.
    return false unless response

    response.success?
  rescue ActiveAd::RecordNotSaved
    false
  end

  # Returns true or exception.
  #
  #   ActiveAd::RecordInvalid (Validation failed: Client can't be blank).
  #   ActiveAd::RecordInvalid (400 Bad Request: {}).
  def save!(**kwargs)
    return true if save(**kwargs)

    raise ActiveAd::RecordInvalid.new(self) if errors.any?
    raise ActiveAd::RecordNotSaved.new(self, @response)
  end

  # Returns true or false.
  def update(**kwargs)
    assign_attributes(kwargs) # Need to set the attributes here so it is in the changed? state before calling save.
    save(**kwargs)
  end

  # Returns true or exception.
  def update!(**kwargs)
    assign_attributes(kwargs) # Need to set the attributes here so it is in the changed? state before calling save.
    save!(**kwargs)
  end

  # Returns true or false.
  def destroy
    @response = nil

    run_callbacks(:destroy) do
      ActiveAd.logger.debug("Calling delete_request with id: #{id}")
      @response = request(delete_request)
    end

    # If an `:abort` was thrown by a `before_destroy` callback or an `ActiveAd::RecordNotDeleted` exception has been raised, there will be no response.
    return false unless response

    response.success?
  rescue ActiveAd::RecordNotDeleted
    false
  end

  # Returns true or exception.
  def destroy!
    destroy || raise(ActiveAd::RecordNotDeleted.new(self, @response))
  end

  # Returns true or false.
  def link(**kwargs)
    @response = nil

    run_callbacks(:link) do
      ActiveAd.logger.debug("Calling link_request with id: #{id}; kwargs: #{kwargs}")
      @response = request(link_request(**kwargs))
    end

    # If an `:abort` was thrown by a `before_link` callback or an `ActiveAd::RecordNotLinked` exception has been raised, there will be no response.
    return false unless response

    response.success?
  rescue ActiveAd::RecordNotLinked
    false
  end

  # Returns true or exception.
  def link!(**kwargs)
    link(**kwargs) || raise(ActiveAd::RecordNotLinked.new(self, @response))
  end

  # Returns true or false.
  def unlink(**kwargs)
    @response = nil

    run_callbacks(:unlink) do
      ActiveAd.logger.debug("Calling unlink_request with id: #{id}; kwargs: #{kwargs}")
      @response = request(unlink_request(**kwargs))
    end

    # If an `:abort` was thrown by a `before_unlink` callback or an `ActiveAd::RecordNotUnlinked` exception has been raised, there will be no response.
    return false unless response

    response.success?
  rescue ActiveAd::RecordNotUnlinked
    false
  end

  # Returns true or exception.
  def unlink!(**kwargs)
    unlink(**kwargs) || raise(ActiveAd::RecordNotUnlinked.new(self, @response))
  end

  def reload(**kwargs)
    find(**kwargs)
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

  # Reserve attribute `validate` to allow skipping of validation on create, save or update. Eg: save(validate: false).
  alias_method :validate, :valid?

  private

  def perform_validations(options = {})
    options[:validate] == false || valid?
  end

  def default_validation_context
    new_record? ? :create : :update
  end

  def assign_attributes(attributes = {})
    return if attributes.nil?

    attributes.each do |attribute, value|
      next if RESERVED_ATTRIBUTES.include?(attribute.to_sym) # Skip reserved attributes.

      attributes = { attribute => value }
      ActiveAd.logger.debug("Assigning attribute with value #{attributes}")
      super(attributes.deep_stringify_keys) # TODO: Try attributes = attributes
    rescue ActiveModel::UnknownAttributeError
      ActiveAd.logger.warn("Tried to assign an unknown attribute (#{attribute}) to #{self.class}")
      next
    end
  end

  # Returns object or nil.
  def find(**kwargs)
    @response = nil

    run_callbacks(:find) do
      ActiveAd.logger.debug("Calling read_request with id: #{id}; kwargs: #{kwargs}")
      @response = request(read_request(**kwargs))
    end

    if response.success?
      assign_attributes(response.body)
      clear_changes_information
    end

    self
  end

  # Returns object or exception.
  #
  #   ActiveAd::RecordNotFound (400 Bad Request: {}).
  #   ActiveAd::RecordNotFound (404 Not Found: {}).
  def find!(**kwargs)
    find(**kwargs)
    raise ActiveAd::RecordNotFound.new(self, @response) unless response.success?

    self
  end

  # Returns the attributes that has been assigned.
  #
  #   attributes                => { "field" => "value", "status" => "PAUSED", "empty_field" => nil }
  #   create_request_attributes => { "field" => "value", "status" => "PAUSED" }
  def create_request_attributes
    attributes.compact
  end

  # Returns the changed attributes in key value format.
  #
  #   changes                   => { "field" => ["old_value", "new_value"], "id" => ["old_value", "new_value"] }
  #   update_request_attributes => { "field" => "new_value" }
  def update_request_attributes
    changes.transform_values(&:last).except(:id) # You can't update an `id`.
  end

  # Exchange attribute keys to map what the external API expects.
  #
  #   attributes         => { "name" => "My Campaign", "status" => "PAUSED" }
  #   attributes_swapped => { "name" => "My Campaign", "platform_status" => "PAUSED" }
  def attributes_swapped
    attributes.deep_transform_keys do |key|
      attribute_aliases.has_value?(key) ? attribute_aliases.key(key) : key
    end
  end

  # Exchange keys to map what the external API expects.
  #
  #   ['name', 'status'] => ['name', 'platform_status']
  #   ['name', 'platform_status'] => ['name', 'platform_status']
  def keys_for_request(keys)
    keys.map { |key| attribute_aliases.invert[key] || key }
  end

  # Exchange keys to map what the internal API expects.
  #
  #   ['name', 'status'] => ['name', 'status']
  #   ['name', 'platform_status'] => ['name', 'status']
  def keys_for_object(keys)
    keys.map { |key| attribute_aliases[key] || key }
  end

  def read_request(**_kwargs)
    raise NotImplementedError, 'Subclasses must implement a read_request method'
  end

  def create_request
    raise NotImplementedError, 'Subclasses must implement a create_request method'
  end

  def update_request
    raise NotImplementedError, 'Subclasses must implement an update_request method'
  end

  def delete_request
    raise NotImplementedError, 'Subclasses must implement a delete_request method'
  end

  def link_request(**_kwargs)
    raise NotImplementedError, 'Subclasses must implement a link_request method'
  end

  def unlink_request(**_kwargs)
    raise NotImplementedError, 'Subclasses must implement an unlink_request method'
  end

  def create_response_id(_response)
    raise NotImplementedError, 'Subclasses must implement a create_response_id method'
  end
end
