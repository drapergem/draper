module Draper
  module AutomaticDelegation
    extend ActiveSupport::Concern

    # Delegates missing instance methods to the source object.
    def method_missing(method, *args, &block)
      return super unless delegatable?(method)

      self.class.delegate method
      send(method, *args, &block)
    end

    # Checks if the decorator responds to an instance method, or is able to
    # proxy it to the source object.
    def respond_to_missing?(method, include_private = false)
      super || delegatable?(method)
    end

    # @private
    def delegatable?(method)
      object.respond_to?(method)
    end

    module ClassMethods
      # Proxies missing class methods to the source class.
      def method_missing(method, *args, &block)
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
