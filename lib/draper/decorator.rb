require 'active_support/core_ext/array/extract_options'
require 'draper'

module Draper
  class Decorator
    include Draper::ViewHelpers
    include ActiveModel::Serialization if defined?(ActiveModel::Serialization)

    attr_accessor :source, :options
    protected :options, :options=

    alias_method :model, :source
    alias_method :to_source, :source

    # Initialize a new decorator instance by passing in
    # an instance of the source class. Pass in an optional
    # :context inside the options hash which is available
    # for later use.
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
    # @option options [Hash] :context context available to the decorator
    def initialize(source, options = {})
      source.to_a if source.respond_to?(:to_a) # forces evaluation of a lazy query from AR
      @source = source
      Draper.validate_options(options, :context)
      @options = options
      handle_multiple_decoration if source.is_a?(Draper::Decorator)
    end

    class << self
      alias_method :decorate, :new
    end

    # Specify the class that this class decorates.
    #
    # @param [String, Symbol, Class] Class or name of class to decorate.
    def self.decorates(klass)
      @source_class = klass.to_s.classify.constantize
    end

    # @return [Class] The source class corresponding to this
    #   decorator class
    def self.source_class
      @source_class ||= inferred_source_class
    end

    # Checks whether this decorator class has a corresponding
    # source class
    def self.source_class?
      source_class
    rescue Draper::UninferrableSourceError
      false
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
    # @option options [Hash, #call] :context context available to decorated
    #   objects in collection.  Passing a `lambda` or similar will result in that
    #   block being called when the association is evaluated.  The block will be
    #   passed the base decorator's `context` Hash and should return the desired
    #   context Hash for the decorated items.
    def self.decorates_association(association, options = {})
      Draper.validate_options(options, :with, :scope, :context)
      define_method(association) do
        decorated_associations[association] ||= Draper::DecoratedAssociation.new(self, association, options)
        decorated_associations[association].call
      end
    end

    # A convenience method for decorating multiple associations. Calls
    # decorates_association on each of the given symbols.
    #
    # @param [Symbols*] associations names of associations to decorate
    # @param [Hash] options passed to `decorate_association`
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
    # @option options [Hash] :context context available to decorated items
    def self.decorate_collection(source, options = {})
      Draper.validate_options(options, :with, :context)
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

    # We always want to delegate present, in case we decorate a nil object.
    #
    # I don't like the idea of decorating a nil object, but we'll deal with
    # that later.
    def present?
      source.present?
    end

    # Accessor for `:context` option
    def context
      options.fetch(:context, {})
    end

    # Setter for `:context` option
    def context=(input)
      options[:context] = input
    end

    # For ActiveModel compatibilty
    def to_model
      self
    end

    # For ActiveModel compatibility
    def to_param
      source.to_param
    end

    def method_missing(method, *args, &block)
      if delegatable_method?(method)
        self.class.define_proxy(method)
        send(method, *args, &block)
      else
        super
      end
    end

    def respond_to?(method, include_private = false)
      super || delegatable_method?(method)
    end

    def self.method_missing(method, *args, &block)
      if delegatable_method?(method)
        source_class.send(method, *args, &block)
      else
        super
      end
    end

    def self.respond_to?(method, include_private = false)
      super || delegatable_method?(method)
    end

    private

    def delegatable_method?(method)
      allow?(method) && source.respond_to?(method)
    end

    def self.delegatable_method?(method)
      source_class? && source_class.respond_to?(method)
    end

    def self.inferred_source_class
      uninferrable_source if name.nil? || name.demodulize !~ /.+Decorator$/

      begin
        name.chomp("Decorator").constantize
      rescue NameError
        uninferrable_source
      end
    end

    def self.uninferrable_source
      raise Draper::UninferrableSourceError.new(self)
    end

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
