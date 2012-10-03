module Draper
  class Base
    require 'active_support/core_ext/class/attribute'
    require 'active_support/core_ext/array/extract_options'

    class_attribute :denied, :allowed, :model_class
    attr_accessor :model, :options

    DEFAULT_DENIED = Object.instance_methods << :method_missing
    DEFAULT_ALLOWED = []
    self.denied = DEFAULT_DENIED
    self.allowed = DEFAULT_ALLOWED

    # Initialize a new decorator instance by passing in
    # an instance of the source class. Pass in an optional
    # context inside the options hash is stored for later use.
    #
    # @param [Object] instance to wrap
    # @param [Hash] options (optional)
    def initialize(input, options = {})
      raise ArgumentError, "Can't decorate an object twice with the same decorator" if input.is_a?(self.class)

      input.inspect # forces evaluation of a lazy query from AR
      self.class.model_class = input.class if model_class.nil?
      @model = input
      self.options = options
      self.extend Draper::ActiveModelSupport::Proxies
    end

    # Proxies to the class specified by `decorates` to automatically
    # lookup an object in the database and decorate it.
    #
    # @param [Symbol or String] id to lookup
    # @return [Object] instance of this decorator class
    def self.find(input, options = {})
      self.new(model_class.find(input), options)
    end

    # Typically called within a decorator definition, this method
    # specifies the name of the wrapped object class.
    #
    # For instance, a `ProductDecorator` class might call `decorates :product`
    #
    # But they don't have to match in name, so a `EmployeeDecorator`
    # class could call `decorates :person` to wrap instances of `Person`
    #
    # This is primarilly set so the `.find` method knows which class
    # to query.
    #
    # @param [Symbol] class_name snakecase name of the decorated class, like `:product`
    def self.decorates(input, options = {})
      self.model_class = options[:class] || options[:class_name] || input.to_s.camelize
      self.model_class = model_class.constantize if model_class.respond_to?(:constantize)
      model_class.send :include, Draper::ModelSupport
      define_method(input){ @model }
    end

    # Typically called within a decorator definition, this method causes
    # the assocation to be decorated when it is retrieved.
    #
    # @param [Symbol] name of association to decorate, like `:products`
    # @option options [Hash] :with The decorator to decorate the association with
    #                        :scope The scope to apply to the association
    def self.decorates_association(association_symbol, options = {})
      define_method(association_symbol) do
        orig_association = model.send(association_symbol)

        return orig_association if orig_association.nil?
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
    # @param [Symbols*] name of associations to decorate
    def self.decorates_associations(*association_symbols)
      options = association_symbols.extract_options!
      association_symbols.each{ |sym| decorates_association(sym, options) }
    end

    # Specifies a black list of methods which may *not* be proxied to
    # to the wrapped object.
    #
    # Do not use both `.allows` and `.denies` together, either write
    # a whitelist with `.allows` or a blacklist with `.denies`
    #
    # @param [Symbols*] methods to deny like `:find, :find_by_name`
    def self.denies(*input_denied)
      raise ArgumentError, "Specify at least one method (as a symbol) to exclude when using denies" if input_denied.empty?
      raise ArgumentError, "Use either 'allows' or 'denies', but not both." unless (self.allowed == DEFAULT_ALLOWED)
      self.denied += input_denied
    end

    # Specifies that all methods may *not* be proxied to
    # to the wrapped object.
    #
    # Do not use `.allows` and `.denies` in combination with '.denies_all'
    def self.denies_all
      raise ArgumentError, "Use either 'allows' or 'denies', but not both." unless ((self.allowed == DEFAULT_ALLOWED && self.denied == DEFAULT_DENIED) || (self.allowed != DEFAULT_ALLOWED && self.denied != DEFAULT_DENIED))
      self.denied  += [nil]  # Add dummy value to denied to prevent calls to #allows.  Hacky???
      self.allowed += [nil]  # Add dummy value to allowed to prevent calls to #denies
    end

    # Specifies a white list of methods which *may* be proxied to
    # to the wrapped object. When `allows` is used, only the listed
    # methods and methods defined in the decorator itself will be
    # available.
    #
    # Do not use both `.allows` and `.denies` together, either write
    # a whitelist with `.allows` or a blacklist with `.denies`
    #
    # @param [Symbols*] methods to allow like `:find, :find_by_name`
    def self.allows(*input_allows)
      raise ArgumentError, "Specify at least one method (as a symbol) to allow when using allows" if input_allows.empty?
      raise ArgumentError, "Use either 'allows' or 'denies', but not both." unless (self.denied == DEFAULT_DENIED)
      self.allowed += input_allows
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
    # @param [Object] instance(s) to wrap
    # @param [Hash] options (optional)
    # @option options [Boolean] :infer If true, each model will be
    #   wrapped by its inferred decorator.
    def self.decorate(input, options = {})
      if input.instance_of?(self)
        input.options = options unless options.empty?
        return input
      elsif input.respond_to?(:each) && !input.is_a?(Struct) && (!defined?(Sequel) || !input.is_a?(Sequel::Model))
        Draper::DecoratedEnumerableProxy.new(input, self, options)
      elsif options[:infer]
        input.decorator(options)
      else
        new(input, options)
      end
    end

    # Fetch all instances of the decorated class and decorate them.
    #
    # @param [Hash] options (optional)
    # @return [Draper::DecoratedEnumerableProxy]
    def self.all(options = {})
      Draper::DecoratedEnumerableProxy.new(model_class.all, self, options)
    end

    def self.first(options = {})
      decorate(model_class.first, options)
    end

    def self.last(options = {})
      decorate(model_class.last, options)
    end

    # Some helpers are private, for example html_escape... as a workaround
    # we are wrapping the helpers in a delegator that passes the methods
    # along through a send, which will ignore private/public distinctions
    class HelpersWrapper
      def initialize(helpers)
        @helpers = helpers
      end

      def method_missing(method, *args, &block)
        @helpers.send(method, *args, &block)
      end

      #needed for tests
      def ==(other)
        other.instance_variable_get(:@helpers) == @helpers
      end
    end

    # Access the helpers proxy to call built-in and user-defined
    # Rails helpers. Aliased to `.h` for convenience.
    #
    # @return [Object] proxy
    def helpers
      HelpersWrapper.new self.class.helpers
    end
    alias :h :helpers

    # Localize is something that's used quite often. Even though
    # it's available through helpers, that's annoying. Aliased
    # to `.l` for convenience.
    def localize(str)
      self.class.helpers.localize(str)
    end
    alias :l :localize

    # Access the helpers proxy to call built-in and user-defined
    # Rails helpers from a class context.
    #
    # @return [Object] proxy
    class << self
      def helpers
        Draper::ViewContext.current
      end
      alias :h :helpers
    end

    # Fetch the original wrapped model.
    #
    # @return [Object] original_model
    def wrapped_object
      @model
    end

    # Delegates == to the decorated models
    #
    # @return [Boolean] true if other's model == self's model
    def ==(other)
      @model == (other.respond_to?(:model) ? other.model : other)
    end

    def kind_of?(klass)
      super || model.kind_of?(klass)
    end
    alias :is_a? :kind_of?

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

    def self.method_missing(method, *args, &block)
      if method.to_s.match(/^find_((all_|last_)?by_|or_(initialize|create)_by_).*/)
        self.decorate(model_class.send(method, *args, &block), :context => args.dup.extract_options!)
      else
        model_class.send(method, *args, &block)
      end
    end

    def self.respond_to?(method, include_private = false)
      super || model_class.respond_to?(method)
    end

    def context
      options.fetch(:context, {})
    end

    def context=(input)
      options[:context] = input
    end

    def source
      model
    end
    alias_method :to_source, :model

  private

    def allow?(method)
      (allowed.empty? || allowed.include?(method)) && !denied.include?(method)
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
