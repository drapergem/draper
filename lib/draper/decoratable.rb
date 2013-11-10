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

    # Decorates the object using the inferred {#decorator_class}.
    # @param [Hash] options
    #   see {Decorator#initialize}
    def decorate(options = {})
      decorator_class.decorate(self, options)
    end

    # (see ClassMethods#decorator_class)
    def decorator_class
      self.class.decorator_class
    end

    def decorator_class?
      self.class.decorator_class?
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
        decorator_class.decorate_collection(collection, options.reverse_merge(with: nil))
      end

      def decorator_class?
        decorator_class
      rescue Draper::UninferrableDecoratorError
        false
      end

      # Infers the decorator class to be used by {Decoratable#decorate} (e.g.
      # `Product` maps to `ProductDecorator`).
      #
      # @return [Class] the inferred decorator class.
      def decorator_class
        prefix = respond_to?(:model_name) ? model_name : name
        decorator_name = "#{prefix}Decorator"
        decorator_name.constantize
      rescue NameError => error
        if superclass.respond_to?(:decorator_class)
          superclass.decorator_class
        else
          raise unless error.missing_name?(decorator_name)
          raise Draper::UninferrableDecoratorError.new(self)
        end
      end

      # Compares with possibly-decorated objects.
      #
      # @return [Boolean]
      def ===(other)
        super || (other.respond_to?(:object) && super(other.object))
      end

    end

  end
end
