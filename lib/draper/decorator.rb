require 'draper/compatibility/global_id'

module Draper
  class Decorator
    include Draper::ViewHelpers
    include Draper::Compatibility::GlobalID if defined?(GlobalID)
    extend Draper::Delegation

    include ActiveModel::Serialization
    include ActiveModel::Serializers::JSON
    include ActiveModel::Serializers::Xml

    # @return the object being decorated.
    attr_reader :object

    alias :model :object

    # @return [Hash] extra data to be used in user-defined methods.
    attr_accessor :context

    # Wraps an object in a new instance of the decorator.
    #
    # Decorators may be applied to other decorators. However, applying a
    # decorator to an instance of itself will create a decorator with the same
    # source as the original, rather than redecorating the other instance.
    #
    # @param [Object] object
    #   object to decorate.
    # @option options [Hash] :context ({})
    #   extra data to be stored in the decorator and used in user-defined
    #   methods.
    def initialize(object, options = {})
      options.assert_valid_keys(:context)
      @object = object
      @context = options.fetch(:context, {})
      handle_multiple_decoration(options) if object.instance_of?(self.class)
    end

    class << self
      alias :decorate :new
    end

    # Automatically delegates instance methods to the source object. Class
    # methods will be delegated to the {object_class}, if it is set.
    #
    # @return [void]
    def self.delegate_all
      include Draper::AutomaticDelegation
    end

    # Sets the source class corresponding to the decorator class.
    #
    # @note This is only necessary if you wish to proxy class methods to the
    #   source (including when using {decorates_finders}), and the source class
    #   cannot be inferred from the decorator class (e.g. `ProductDecorator`
    #   maps to `Product`).
    # @param [String, Symbol, Class] object_class
    #   source class (or class name) that corresponds to this decorator.
    # @return [void]
    def self.decorates(object_class)
      @object_class = object_class.to_s.camelize.constantize
      alias_object_to_object_class_name
    end

    # Returns the source class corresponding to the decorator class, as set by
    # {decorates}, or as inferred from the decorator class name (e.g.
    # `ProductDecorator` maps to `Product`).
    #
    # @return [Class] the source class that corresponds to this decorator.
    def self.object_class
      @object_class ||= inferred_object_class
    end

    # Checks whether this decorator class has a corresponding {object_class}.
    def self.object_class?
      object_class
    rescue Draper::UninferrableObjectError
      false
    end

    # Automatically decorates ActiveRecord finder methods, so that you can use
    # `ProductDecorator.find(id)` instead of
    # `ProductDecorator.decorate(Product.find(id))`.
    #
    # Finder methods are applied to the {object_class}.
    #
    # @return [void]
    def self.decorates_finders
      extend Draper::Finders
    end

    # Automatically decorate an association.
    #
    # @param [Symbol] association
    #   name of the association to decorate (e.g. `:products`).
    # @option options [Class] :with
    #   the decorator to apply to the association.
    # @option options [Symbol] :scope
    #   a scope to apply when fetching the association.
    # @option options [Hash, #call] :context
    #   extra data to be stored in the associated decorator. If omitted, the
    #   associated decorator's context will be the same as the parent
    #   decorator's. If a Proc is given, it will be called with the parent's
    #   context and should return a new context hash for the association.
    # @return [void]
    def self.decorates_association(association, options = {})
      options.assert_valid_keys(:with, :scope, :context)
      define_method(association) do
        decorated_associations[association] ||= Draper::DecoratedAssociation.new(self, association, options)
        decorated_associations[association].call
      end
    end

    # @overload decorates_associations(*associations, options = {})
    #   Automatically decorate multiple associations.
    #   @param [Symbols*] associations
    #     names of the associations to decorate.
    #   @param [Hash] options
    #     see {decorates_association}.
    #   @return [void]
    def self.decorates_associations(*associations)
      options = associations.extract_options!
      associations.each do |association|
        decorates_association(association, options)
      end
    end

    # Decorates a collection of objects. The class of the collection decorator
    # is inferred from the decorator class if possible (e.g. `ProductDecorator`
    # maps to `ProductsDecorator`), but otherwise defaults to
    # {Draper::CollectionDecorator}.
    #
    # @param [Object] object
    #   collection to decorate.
    # @option options [Class, nil] :with (self)
    #   the decorator class used to decorate each item. When `nil`, it is
    #   inferred from each item.
    # @option options [Hash] :context
    #   extra data to be stored in the collection decorator.
    def self.decorate_collection(object, options = {})
      options.assert_valid_keys(:with, :context)
      collection_decorator_class.new(object, options.reverse_merge(with: self))
    end

    # @return [Array<Class>] the list of decorators that have been applied to
    #   the object.
    def applied_decorators
      chain = object.respond_to?(:applied_decorators) ? object.applied_decorators : []
      chain << self.class
    end

    # Checks if a given decorator has been applied to the object.
    #
    # @param [Class] decorator_class
    def decorated_with?(decorator_class)
      applied_decorators.include?(decorator_class)
    end

    # Checks if this object is decorated.
    #
    # @return [true]
    def decorated?
      true
    end

    # Compares the source object with a possibly-decorated object.
    #
    # @return [Boolean]
    def ==(other)
      Draper::Decoratable::Equality.test(object, other)
    end

    # Delegates equality to :== as expected
    #
    # @return [Boolean]
    def eql?(other)
      self == other
    end

    # Returns a unique hash for a decorated object based on
    # the decorator class and the object being decorated.
    #
    # @return [Fixnum]
    def hash
      self.class.hash ^ object.hash
    end

    # Checks if `self.kind_of?(klass)` or `object.kind_of?(klass)`
    #
    # @param [Class] klass
    def kind_of?(klass)
      super || object.kind_of?(klass)
    end

    alias :is_a? :kind_of?

    # Checks if `self.instance_of?(klass)` or `object.instance_of?(klass)`
    #
    # @param [Class] klass
    def instance_of?(klass)
      super || object.instance_of?(klass)
    end

    delegate :to_s

    # In case object is nil
    delegate :present?, :blank?

    # ActiveModel compatibility
    # @private
    def to_model
      self
    end

    # @return [Hash] the object's attributes, sliced to only include those
    # implemented by the decorator.
    def attributes
      object.attributes.select {|attribute, _| respond_to?(attribute) }
    end

    # ActiveModel compatibility
    delegate :to_param, :to_partial_path

    # ActiveModel compatibility
    singleton_class.delegate :model_name, to: :object_class

    # @return [Class] the class created by {decorate_collection}.
    def self.collection_decorator_class
      name = collection_decorator_name
      name_constant = name&.safe_constantize

      name_constant || Draper::CollectionDecorator
    end

    private

    def self.inherited(subclass)
      subclass.alias_object_to_object_class_name
      super
    end

    def self.alias_object_to_object_class_name
      alias_method object_class.name.underscore, :object if object_class?
    end

    def self.object_class_name
      return nil if name.nil? || name.demodulize !~ /.+Decorator$/
      name.chomp("Decorator")
    end

    def self.inferred_object_class
      name = object_class_name
      name_constant = name&.safe_constantize
      return name_constant unless name_constant.nil?

      raise Draper::UninferrableObjectError.new(self)
    end

    def self.collection_decorator_name
      singular = object_class_name
      plural = singular&.pluralize

      "#{plural}Decorator" unless plural == singular
    end

    def handle_multiple_decoration(options)
      if object.applied_decorators.last == self.class
        @context = object.context unless options.has_key?(:context)
        @object = object.object
      else
        warn "Reapplying #{self.class} decorator to target that is already decorated with it. Call stack:\n#{caller(1).join("\n")}"
      end
    end

    def decorated_associations
      @decorated_associations ||= {}
    end
  end
end
