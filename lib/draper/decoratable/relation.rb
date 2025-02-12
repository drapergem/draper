module Draper
  module Decoratable
    module Relation
      # Decorates a relation of objects. Used at the end of a scope chain.
      #
      # @example
      #   Product.popular.decorate
      # @param [Hash] options
      #   see {Decorator.decorate_collection}.
      def decorate(options = {})
        decorator_class.decorate_collection(self, options.reverse_merge(with: nil))
      end
    end
  end
end
