module Draper
  module Decoratable
    module CollectionProxy
      # Decorates a collection of objects. Used at the end of a scope chain.
      #
      # @example
      #   company.products.popular.decorate
      # @param [Hash] options
      #   see {Decorator.decorate_collection}.
      def decorate(options = {})
        decorator_class.decorate_collection(load_target, options.reverse_merge(with: nil))
      end
    end
  end
end
