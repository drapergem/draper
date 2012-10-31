require 'active_support/core_ext/array/extract_options'

module Draper
  class Decorator
    include ActiveModelSupport
    include Draper::ViewHelpers

    attr_accessor :model, :options

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
    # @param [Object] input instance to wrap
    # @param [Hash] options (optional)
    def initialize(input, options = {})
      input.to_a if input.respond_to?(:to_a) # forces evaluation of a lazy query from AR
      self.model = input
      self.options = options
      handle_multiple_decoration if input.is_a?(Draper::Decorator)
    end

    # Adds ActiveRecord finder methods to the decorator class. The
    # methods return decorated models, so that you can use
    # `ProductDecorator.find(id)` instead of
    # `ProductDecorator.decorate(Product.find(id))`.
    #
    # If the `:for` option is not supplied, the model class will be
    # inferred from the decorator class.
    #
    # @option options [Class, Symbol] :for The model class to find
    def self.has_finders(options = {})
      extend Draper::Finders
      self.finder_class = options[:for] || name.chomp("Decorator")
    end

    # Typically called within a decorator definition, this method causes
    # the assocation to be decorated when it is retrieved.
    #
    # @param [Symbol] association_symbol name of association to decorate, like `:products`
    # @option options [Hash] :with The decorator to decorate the association with
    #                        :scope The scope to apply to the association
    def self.decorates_association(association_symbol, options = {})
      define_method(association_symbol) do
        orig_association = model.send(association_symbol)

        return orig_association if orig_association.nil? || orig_association == []
        return decorated_associations[association_symbol] if decorated_associations[association_symbol]

        orig_association = orig_association.send(options[:scope]) if options[:scope]

        return options[:with].decorate(orig_association) if options[:with]

        klass = if options[:polymorphic]
                  orig_association.class
                elsif association_reflection = find_association_reflection(association_symbol)
                  association_reflection.klass
                elsif orig_association.respond_to?(:first)
                  orig_association.first.class
                else
                  orig_association.class
                end

        decorated_associations[association_symbol] = "#{klass}Decorator".constantize.decorate(orig_association, options)
      end
    end

    # A convenience method for decorating multiple associations. Calls
    # decorates_association on each of the given symbols.
    #
    # @param [Symbols*] association_symbols name of associations to decorate
    def self.decorates_associations(*association_symbols)
      options = association_symbols.extract_options!
      association_symbols.each{ |sym| decorates_association(sym, options) }
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

    # Initialize a new decorator instance by passing in
    # an instance of the source class. Pass in an optional
    # context into the options hash is stored for later use.
    #
    # When passing in a single object, using `.decorate` is
    # identical to calling `.new`. However, `.decorate` can
    # also accept a collection and return a collection of
    # individually decorated objects.
    #
    # @param [Object] input instance(s) to wrap
    # @param [Hash] options (optional)
    # @option options [Boolean] :infer If true, each model will be
    #   wrapped by its inferred decorator.
    def self.decorate(input, options = {})
      if input.instance_of?(self)
        input.options = options unless options.empty?
        return input
      elsif input.respond_to?(:each) && !input.is_a?(Struct) && (!defined?(Sequel) || !input.is_a?(Sequel::Model))
        Draper::CollectionDecorator.new(input, options.merge(with: self))
      elsif options[:infer]
        input.decorator(options)
      else
        new(input, options)
      end
    end

    # Get the chain of decorators applied to the object.
    #
    # @return [Array] list of decorator classes
    def applied_decorators
      chain = model.respond_to?(:applied_decorators) ? model.applied_decorators : []
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

    def decorator
      self
    end
    alias_method :decorate, :decorator

    # Delegates == to the decorated models
    #
    # @return [Boolean] true if other's model == self's model
    def ==(other)
      @model == (other.respond_to?(:model) ? other.model : other)
    end

    def kind_of?(klass)
      super || model.kind_of?(klass)
    end
    alias_method :is_a?, :kind_of?

    def respond_to?(method, include_private = false)
      super || (allow?(method) && model.respond_to?(method, include_private))
    end

    # We always want to delegate present, in case we decorate a nil object.
    #
    # I don't like the idea of decorating a nil object, but we'll deal with
    # that later.
    def present?
      model.present?
    end

    def method_missing(method, *args, &block)
      super unless allow?(method)

      if model.respond_to?(method)
        self.class.send :define_method, method do |*args, &blokk|
          model.send method, *args, &blokk
        end

        send method, *args, &block
      else
        super
      end

    rescue NoMethodError => no_method_error
      super if no_method_error.name == method
      raise no_method_error
    end

    def context
      options.fetch(:context, {})
    end

    def context=(input)
      options[:context] = input
    end

    alias_method :wrapped_object, :model
    alias_method :source, :model
    alias_method :to_source, :model

  private

    def self.security
      @security ||= Security.new
    end

    def allow?(method)
      self.class.security.allow?(method)
    end

    def handle_multiple_decoration
      if model.instance_of?(self.class)
        self.model = model.model
      elsif model.decorated_with?(self.class)
        warn "Reapplying #{self.class} decorator to target that is already decorated with it. Call stack:\n#{caller(1).join("\n")}"
      end
    end

    def find_association_reflection(association)
      if model.class.respond_to?(:reflect_on_association)
        model.class.reflect_on_association(association)
      end
    end

    def decorated_associations
      @decorated_associations ||= {}
    end
  end
end
