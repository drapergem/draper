require 'active_support/core_ext/array/extract_options'

module Draper
  class Decorator
    include Draper::ViewHelpers
    include ActiveModel::Serialization if defined?(ActiveModel::Serialization)

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
      source.to_a if source.respond_to?(:to_a) # forces evaluation of a lazy query from AR
      @source = source
      @context = options.fetch(:context, {})
      handle_multiple_decoration(options) if source.instance_of?(self.class)
    end

    class << self
      alias_method :decorate, :new
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

    # Specifies a blacklist of methods which are not to be automatically
    # proxied to the source object.
    #
    # @note Use only one of {allows}, {denies}, and {denies_all}.
    # @param [Symbols*] methods
    #   list of methods not to be automatically proxied.
    # @return [void]
    def self.denies(*methods)
      security.denies(*methods)
    end

    # Prevents all methods from being automatically proxied to the source
    # object.
    #
    # @note (see denies)
    # @return [void]
    def self.denies_all
      security.denies_all
    end

    # Specifies a whitelist of methods which are to be automatically proxied to
    # the source object.
    #
    # @note (see denies)
    # @param [Symbols*] methods
    #   list of methods to be automatically proxied.
    # @return [void]
    def self.allows(*methods)
      security.allows(*methods)
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

    # Delegated to the source object.
    #
    # @return [Boolean]
    def ==(other)
      source == (other.respond_to?(:source) ? other.source : other)
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

    # Delegated to the source object, in case it is `nil`.
    def present?
      source.present?
    end

    # For ActiveModel compatibility.
    # @return [self]
    def to_model
      self
    end

    # Delegated to the source object for ActiveModel compatibility.
    def to_param
      source.to_param
    end

    # Proxies missing instance methods to the source object.
    def method_missing(method, *args, &block)
      if delegatable_method?(method)
        self.class.define_proxy(method)
        send(method, *args, &block)
      else
        super
      end
    end

    # Checks if the decorator responds to an instance method, or is able to
    # proxy it to the source object.
    def respond_to?(method, include_private = false)
      super || delegatable_method?(method)
    end

    # Proxies missing class methods to the {source_class}.
    def self.method_missing(method, *args, &block)
      if delegatable_method?(method)
        source_class.send(method, *args, &block)
      else
        super
      end
    end

    # Checks if the decorator responds to a class method, or is able to proxy
    # it to the {source_class}.
    def self.respond_to?(method, include_private = false)
      super || delegatable_method?(method)
    end

    # @return [Class] the class created by {decorate_collection}.
    def self.collection_decorator_class
      collection_decorator_name.constantize
    rescue NameError
      Draper::CollectionDecorator
    end

    private

    def delegatable_method?(method)
      allow?(method) && source.respond_to?(method)
    end

    def self.delegatable_method?(method)
      source_class? && source_class.respond_to?(method)
    end

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

    def self.define_proxy(method)
      define_method(method) do |*args, &block|
        source.send(method, *args, &block)
      end
    end

    def self.security
      @security ||= Security.new(superclass_security)
    end

    def self.security?
      @security || (superclass.respond_to?(:security?) && superclass.security?)
    end

    def self.superclass_security
      return nil unless superclass.respond_to?(:security)
      superclass.security
    end

    def allow?(method)
      self.class.allow?(method)
    end

    def self.allow?(method)
      !security? || security.allow?(method)
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
