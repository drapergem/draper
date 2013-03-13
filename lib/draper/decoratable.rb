require 'draper/decoratable/equality'

module Draper
  # Provides shortcuts to decorate objects directly, so you can do
  # `@product.decorate` instead of `ProductDecorator.new(@product)`.
  #
  # This module is included by default into `ActiveRecord::Base` and
  # `Mongoid::Document`, but you're using another ORM, or want to decorate
  # plain old Ruby objects, you can include it manually.
  module Decoratable
    extend ActiveSupport::Concern
    include Draper::Decoratable::Equality

    VALID_OPTIONS = [:namespace] + Decorator::VALID_OPTIONS

    # Decorates the object using the inferred {#decorator_class}.
    # @param [Hash] options
    #   see {Decorator#initialize}
    def decorate(options = {})
      options.assert_valid_keys(Decoratable::VALID_OPTIONS)
      decorator_class(options).decorate(self, options.slice(*Decorator::VALID_OPTIONS))
    end

    # (see ClassMethods#decorator_class)
    def decorator_class(options = {})
      self.class.decorator_class(options)
    end

    # The list of decorators that have been applied to the object.
    #
    # @return [Array<Class>] `[]`
    def applied_decorators
      []
    end

    # (see Decorator#decorated_with?)
    # @return [false]
    def decorated_with?(decorator_class)
      false
    end

    # Checks if this object is decorated.
    #
    # @return [false]
    def decorated?
      false
    end

    module ClassMethods

      # Decorates a collection of objects. Used at the end of a scope chain.
      #
      # @example
      #   Product.popular.decorate
      # @param [Hash] options
      #   see {Decorator.decorate_collection}.
      def decorate(options = {})
        collection = Rails::VERSION::MAJOR >= 4 ? all : scoped
        decorator_class(options).decorate_collection(collection, options.reverse_merge(with: nil))
      end

      # Infers the decorator class to be used by {Decoratable#decorate} (e.g.
      # `Product` maps to `ProductDecorator`).
      #
      # @option options [Module, nil] :namespace (nil)
      #   a namespace within which to look for an inferred decorator (e.g. if
      #   +:namespace => API+, a model +Product+ would be decorated with
      #   +API::ProductDecorator+ (if defined)
      # @return [Class] the inferred decorator class.
      def decorator_class(options = {})
        prefix         = respond_to?(:model_name) ? model_name : name
        namespace      = options[:namespace]
        base_name      = "#{prefix}Decorator"
        decorator_name = namespace ? "#{namespace.name}::#{base_name}" : base_name

        decorator_name.constantize
      rescue NameError => error
        raise unless error.missing_name?(decorator_name)
        raise Draper::UninferrableDecoratorError.new(self)
      end

      # Compares with possibly-decorated objects.
      #
      # @return [Boolean]
      def ===(other)
        super || (other.respond_to?(:source) && super(other.source))
      end

    end

  end
end
