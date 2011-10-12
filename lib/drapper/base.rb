module Drapper
  class Base
    require 'active_support/core_ext/class/attribute'
    class_attribute :denied, :allowed, :model_class
    attr_accessor :context, :model

    DEFAULT_DENIED = Object.new.methods << :method_missing
    FORCED_PROXY = [:to_param]
    FORCED_PROXY.each do |method|
      define_method method do |*args, &block|
        model.send method, *args, &block
      end
    end
    self.denied = DEFAULT_DENIED

    # Initialize a new decorator instance by passing in
    # an instance of the source class. Pass in an optional
    # context is stored for later use.
    #
    # @param [Object] instance to wrap
    # @param [Object] context (optional)
    def initialize(input, context = {})
      input.inspect # forces evaluation of a lazy query from AR
      input.inspect
      self.class.model_class = input.class if model_class.nil?
      @model = input
      self.context = context
    end

    # Proxies to the class specified by `decorates` to automatically
    # lookup an object in the database and decorate it.
    #
    # @param [Symbol or String] id to lookup
    # @return [Object] instance of this decorator class
    def self.find(input, context = {})
      self.new(model_class.find(input), context)
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
    def self.decorates(input)
      self.model_class = input.to_s.camelize.constantize
      model_class.send :include, Drapper::ModelSupport
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
      raise ArgumentError, "Use either 'allows' or 'denies', but not both." if self.allowed?
      self.denied += input_denied
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
      self.allowed = input_allows
    end

    # Initialize a new decorator instance by passing in
    # an instance of the source class. Pass in an optional
    # context is stored for later use.
    #
    # When passing in a single object, using `.decorate` is
    # identical to calling `.new`. However, `.decorate` can
    # also accept a collection and return a collection of
    # individually decorated objects.
    #
    # @param [Object] instance(s) to wrap
    # @param [Object] context (optional)
    def self.decorate(input, context = {})
      input.respond_to?(:each) ? input.map{|i| new(i, context)} : new(input, context)
    end

    # Access the helpers proxy to call built-in and user-defined
    # Rails helpers. Aliased to `.h` for convinience.
    #
    # @return [Object] proxy   
    def helpers
      Thread.current[:current_view_context]
    end
    alias :h :helpers

    # Calling `lazy_helpers` will make the built-in and
    # user-defined Rails helpers accessible as class methods
    # in the decorator without using the `h.` or `helpers.` proxy.
    #
    # The drawback is that you dump many methods into your decorator's
    # namespace and collisions could create unexpected results.
    def self.lazy_helpers
      self.send(:include, Drapper::LazyHelpers)
    end

    # Fetch the original wrapped model.
    #
    # @return [Object] original_model
    def to_model
      @model
    end

    # Delegates == to the decorated models
    #
    # @return [Boolean] true if other's model == self's model 
    def ==(other)
      @model == other.model
    end

    def respond_to?(method, include_private = false)
      if select_methods.include?(method)
        model.respond_to?(method)
      else
        super
      end
    end

    def method_missing(method, *args, &block)
      if select_methods.include?(method)
        model.send(method, *args, &block)
      else
        super
      end
    end
    
    def self.method_missing(method, *args, &block)
      model_class.send(method, *args, &block)
    end
    
    def self.respond_to?(method, include_private = false)
      super || model_class.respond_to?(method)
    end

  private
    def select_methods
      specified = self.allowed || (model.public_methods.map{|s| s.to_sym} - denied.map{|s| s.to_sym})
      (specified - self.public_methods.map{|s| s.to_sym}) + FORCED_PROXY
    end
  end
end
