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
    def respond_to?(method, include_private = false)
      super || delegatable?(method)
    end

    # @private
    def delegatable?(method)
      source.respond_to?(method)
    end

    module ClassMethods
      # Proxies missing class methods to the source class.
      def method_missing(method, *args, &block)
        return super unless delegatable?(method)

        source_class.send(method, *args, &block)
      end

      # Checks if the decorator responds to a class method, or is able to proxy
      # it to the source class.
      def respond_to?(method, include_private = false)
        super || delegatable?(method)
      end

      # @private
      def delegatable?(method)
        source_class? && source_class.respond_to?(method)
      end
    end

    included do
      private :delegatable?
      private_class_method :delegatable?
    end

  end
end
