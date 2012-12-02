require 'active_support/core_ext/array/extract_options'

module Draper
  class Decorator
    include Draper::ViewHelpers
    include ActiveModel::Serialization if defined?(ActiveModel::Serialization)

    attr_accessor :source, :options

    alias_method :model, :source
    alias_method :to_source, :source

    # Initialize a new decorator instance by passing in
    # an instance of the source class. Pass in an optional
    # context inside the options hash is stored for later use.
    #
    # A decorator cannot be applied to other instances of the
    # same decorator and will instead result in a decorator
    # with the same target as the original.
    # You can, however, apply several decorators in a chain but
    # you will get a warning if the same decorator appears at
    # multiple places in the chain.
    #
    # @param [Object] source object to decorate
    # @param [Hash] options (optional)
    def initialize(source, options = {})
      source.to_a if source.respond_to?(:to_a) # forces evaluation of a lazy query from AR
      @source = source
      @options = options
      handle_multiple_decoration if source.is_a?(Draper::Decorator)
    end

    class << self
      alias_method :decorate, :new
    end

    class << self
      UNKNOWN_SOURCE_ERROR_MESSAGE = "Cannot find source_class for %s. Use `decorates` to specify the source_class."

      # Specify the class that this class decorates.
      #
      # @param [String, Symbol, Class] Class or name of class to decorate.
      def decorates(klass)
        @source_class = klass.kind_of?(Class) ? klass : klass.to_s.classify.constantize
      end

      # Provides access to the class that this decorator decorates
      #
      # @return [Class]: The class wrapped by the decorator
      def source_class
        @source_class ||= begin
          raise NameError.new(UNKNOWN_SOURCE_ERROR_MESSAGE % "<unnamed decorator>") if name.nil? or name.chomp("Decorator").blank?
          begin
            name.chomp("Decorator").constantize
          rescue NameError
            raise NameError.new(UNKNOWN_SOURCE_ERROR_MESSAGE % "`#{name.chomp("Decorator")}`")
          end
        end
      end

      def method_missing(method, *args, &block)
        # We see if we have a valid source here rather than in the #send since we don't want to accidentally capture
        # NameError raised by a method called on a valid #source_class
        begin
          source_class
        rescue NameError
          return super
        end

        # If we pass the source_class invocation, then we can send the method on to the decorated class.
        source_class.send(method, *args, &block)
      end

      def respond_to?(method, include_private = false)
        super || begin
          source_class.respond_to?(method)
        rescue NameError
          false
        end
      end
    end

    # Automatically decorates ActiveRecord finder methods, so that
    # you can use `ProductDecorator.find(id)` instead of
    # `ProductDecorator.decorate(Product.find(id))`.
    #
    # The model class to be found is defined by `decorates` or
    # inferred from the decorator class name.
    #
    def self.decorates_finders
      extend Draper::Finders
    end

    # Typically called within a decorator definition, this method causes
    # the assocation to be decorated when it is retrieved.
    #
    # @param [Symbol] association name of association to decorate, like `:products`
    # @option options [Class] :with the decorator to apply to the association
    # @option options [Symbol] :scope a scope to apply when fetching the association
    def self.decorates_association(association, options = {})
      define_method(association) do
        decorated_associations[association] ||= Draper::DecoratedAssociation.new(source, association, options)
        decorated_associations[association].call
      end
    end

    # A convenience method for decorating multiple associations. Calls
    # decorates_association on each of the given symbols.
    #
    # @param [Symbols*] associations name of associations to decorate
    def self.decorates_associations(*associations)
      options = associations.extract_options!
      associations.each do |association|
        decorates_association(association, options)
      end
    end

    # Specifies a black list of methods which may *not* be proxied to
    # the wrapped object.
    #
    # Do not use both `.allows` and `.denies` together, either write
    # a whitelist with `.allows` or a blacklist with `.denies`
    #
    # @param [Symbols*] methods methods to deny like `:find, :find_by_name`
    def self.denies(*methods)
      security.denies(*methods)
    end

    # Specifies that all methods may *not* be proxied to the wrapped object.
    #
    # Do not use `.allows` and `.denies` in combination with '.denies_all'
    def self.denies_all
      security.denies_all
    end

    # Specifies a white list of methods which *may* be proxied to
    # the wrapped object. When `allows` is used, only the listed
    # methods and methods defined in the decorator itself will be
    # available.
    #
    # Do not use both `.allows` and `.denies` together, either write
    # a whitelist with `.allows` or a blacklist with `.denies`
    #
    # @param [Symbols*] methods methods to allow like `:find, :find_by_name`
    def self.allows(*methods)
      security.allows(*methods)
    end

    # Creates a new CollectionDecorator for the given collection.
    #
    # @param [Object] source collection to decorate
    # @param [Hash] options passed to each item's decorator (except
    #   for the keys listed below)
    # @option options [Class,Symbol] :with (self) the class used to decorate
    #   items, or `:infer` to call each item's `decorate` method instead
    def self.decorate_collection(source, options = {})
      Draper::CollectionDecorator.new(source, options.reverse_merge(with: self))
    end

    # Get the chain of decorators applied to the object.
    #
    # @return [Array] list of decorator classes
    def applied_decorators
      chain = source.respond_to?(:applied_decorators) ? source.applied_decorators : []
      chain << self.class
    end

    # Checks if a given decorator has been applied.
    #
    # @param [Class] decorator_class
    def decorated_with?(decorator_class)
      applied_decorators.include?(decorator_class)
    end

    def decorated?
      true
    end

    # Delegates == to the decorated models
    #
    # @return [Boolean] true if other's model == self's model
    def ==(other)
      source == (other.respond_to?(:source) ? other.source : other)
    end

    def kind_of?(klass)
      super || source.kind_of?(klass)
    end
    alias_method :is_a?, :kind_of?

    def respond_to?(method, include_private = false)
      super || (allow?(method) && source.respond_to?(method, include_private))
    end

    # We always want to delegate present, in case we decorate a nil object.
    #
    # I don't like the idea of decorating a nil object, but we'll deal with
    # that later.
    def present?
      source.present?
    end

    def method_missing(method, *args, &block)
      if allow?(method) && source.respond_to?(method)
        self.class.define_proxy(method)
        send(method, *args, &block)
      else
        super
      end
    end

    # For ActiveModel compatibilty
    def to_model
      self
    end

    # For ActiveModel compatibility
    def to_param
      source.to_param
    end

    private

    def self.define_proxy(method)
      define_method(method) do |*args, &block|
        source.send(method, *args, &block)
      end
    end

    def self.security
      @security ||= Security.new
    end

    def allow?(method)
      self.class.security.allow?(method)
    end

    def handle_multiple_decoration
      if source.instance_of?(self.class)
        self.options = source.options if options.empty?
        self.source = source.source
      elsif source.decorated_with?(self.class)
        warn "Reapplying #{self.class} decorator to target that is already decorated with it. Call stack:\n#{caller(1).join("\n")}"
      end
    end

    def decorated_associations
      @decorated_associations ||= {}
    end
  end
end
