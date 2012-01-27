module ActiveRecord
  class Base

    def self.limit
      tap do
        instance_eval do
          @collection = [new]
          singleton_class.delegate :each, :size, :map, :to => :@collection
        end
      end
    end

  end
end
