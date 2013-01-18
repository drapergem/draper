module Draper
  module Decoratable
    module Equality
      # Compares self with a possibly-decorated object.
      #
      # @return [Boolean]
      def ==(other)
        super ||
          other.respond_to?(:decorated?) && other.decorated? &&
          other.respond_to?(:source) && self == other.source
      end
    end
  end
end
