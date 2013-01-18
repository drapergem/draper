module Draper
  class Decorator
    include Draper::ViewHelpers
    extend Draper::Delegation
    include ActiveModel::Serialization

    # @return the object being decorated.
    attr_reader :source
    alias_method :model, :source
    alias_method :to_source, :source

    # @return [Hash] extra data to be used in user-defined methods.
    attr_accessor :context

    # Wraps an object in a new instance of the decorator.
    #
    # Decorators may be applied to other decorators. However, applying a
    # decorator to an instance of itself will create a decorator with the same
    # source as the original, rather than redecorating the other instance.
    #
    # @param [Object] source
    #   object to decorate.
    # @option options [Hash] :context ({})
    #   extra data to be stored in the decorator and used in user-defined
    #   methods.
    def initialize(source, options = {})
      options.assert_valid_keys(:context)
      @source = source
      @context = options.fetch(:context, {})
      handle_multiple_decoration(options) if source.instance_of?(self.class)
    end

    class << self
      alias_method :decorate, :new
    end

    # Automatically delegates instance methods to the source object. Class
    # methods will be delegated to the {source_class}, if it is set.
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
    # @param [String, Symbol, Class] source_class
    #   source class (or class name) that corresponds to this decorator.
    # @return [void]
    def self.decorates(source_class)
      @source_class = source_class.to_s.camelize.constantize
    end

    # Returns the source class corresponding to the decorator class, as set by
    # {decorates}, or as inferred from the decorator class name (e.g.
    # `ProductDecorator` maps to `Product`).
    #
    # @return [Class] the source class that corresponds to this decorator.
    def self.source_class
      @source_class ||= inferred_source_class
    end

    # Checks whether this decorator class has a corresponding {source_class}.
    def self.source_class?
      source_class
    rescue Draper::UninferrableSourceError
      false
    end

    # Automatically decorates ActiveRecord finder methods, so that you can use
    # `ProductDecorator.find(id)` instead of
    # `ProductDecorator.decorate(Product.find(id))`.
    #
    # Finder methods are applied to the {source_class}.
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
    # @param [Object] source
    #   collection to decorate.
    # @option options [Class, nil] :with (self)
    #   the decorator class used to decorate each item. When `nil`, it is
    #   inferred from each item.
    # @option options [Hash] :context
    #   extra data to be stored in the collection decorator.
    def self.decorate_collection(source, options = {})
      options.assert_valid_keys(:with, :context)
      collection_decorator_class.new(source, options.reverse_merge(with: self))
    end

    # @return [Array<Class>] the list of decorators that have been applied to
    #   the object.
    def applied_decorators
      chain = source.respond_to?(:applied_decorators) ? source.applied_decorators : []
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

    # Compares the source with a possibly-decorated object.
    #
    # @return [Boolean]
    def ==(other)
      source.extend(Draper::Decoratable::Equality) == other
    end

    # Checks if `self.kind_of?(klass)` or `source.kind_of?(klass)`
    #
    # @param [Class] klass
    def kind_of?(klass)
      super || source.kind_of?(klass)
    end
    alias_method :is_a?, :kind_of?

    # Checks if `self.instance_of?(klass)` or `source.instance_of?(klass)`
    #
    # @param [Class] klass
    def instance_of?(klass)
      super || source.instance_of?(klass)
    end

    # In case source is nil
    delegate :present?

    # ActiveModel compatibility
    # @private
    def to_model
      self
    end

    # ActiveModel compatibility
    delegate :attributes, :to_param, :to_partial_path

    # ActiveModel compatibility
    singleton_class.delegate :model_name, to: :source_class

    # @return [Class] the class created by {decorate_collection}.
    def self.collection_decorator_class
      collection_decorator_name.constantize
    rescue NameError
      Draper::CollectionDecorator
    end

    private

    def self.source_name
      raise NameError if name.nil? || name.demodulize !~ /.+Decorator$/
      name.chomp("Decorator")
    end

    def self.inferred_source_class
      source_name.constantize
    rescue NameError
      raise Draper::UninferrableSourceError.new(self)
    end

    def self.collection_decorator_name
      plural = source_name.pluralize
      raise NameError if plural == source_name
      "#{plural}Decorator"
    end

    def handle_multiple_decoration(options)
      if source.applied_decorators.last == self.class
        @context = source.context unless options.has_key?(:context)
        @source = source.source
      else
        warn "Reapplying #{self.class} decorator to target that is already decorated with it. Call stack:\n#{caller(1).join("\n")}"
      end
    end

    def decorated_associations
      @decorated_associations ||= {}
    end
  end
end
