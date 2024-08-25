module Draper
  module AutomaticDelegation
    extend ActiveSupport::Concern

    # Delegates missing instance methods to the source object. Note: This will delegate `super`
    # method calls to `object` as well. Calling `super` will first try to call the method on
    # the parent decorator class. If no method exists on the parent class, it will then try
    # to call the method on the `object`.
    ruby2_keywords def method_missing(method, *args, &block)
      return super unless delegatable?(method)

      object.send(method, *args, &block)
    end

    # Checks if the decorator responds to an instance method, or is able to
    # proxy it to the source object.
    def respond_to_missing?(method, include_private = false)
      super || delegatable?(method)
    end

    # @private
    def delegatable?(method)
      return if private_methods(false).include?(method)

      object.respond_to?(method)
    end

    module ClassMethods
      # Proxies missing class methods to the source class.
      ruby2_keywords def method_missing(method, *args, &block)
        return super unless delegatable?(method)

        object_class.send(method, *args, &block)
      end

      # Checks if the decorator responds to a class method, or is able to proxy
      # it to the source class.
      def respond_to_missing?(method, include_private = false)
        super || delegatable?(method)
      end

      # @private
      def delegatable?(method)
        object_class? && object_class.respond_to?(method)
      end

      # @private
      # Avoids reloading the model class when ActiveSupport clears autoloaded
      # dependencies in development mode.
      def before_remove_const
      end
    end

    included do
      private :delegatable?
      private_class_method :delegatable?
    end

  end
end
