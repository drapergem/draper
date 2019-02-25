module Draper
  module QueryMethods
    module LoadStrategy
      def self.new(name)
        const_get(name.to_s.camelize).new
      end

      class ActiveRecord
        def allowed?(method)
          ::ActiveRecord::Relation::VALUE_METHODS.include? method
        end
      end

      class Mongoid
        def allowed?(method)
          raise NotImplementedError
        end
      end
    end
  end
end
