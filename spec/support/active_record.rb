module ActiveRecord
  class Base
    include ActiveModel::Validations
    include ActiveModel::Conversion

    attr_reader :errors, :to_model

    def initialize
      @errors = ActiveModel::Errors.new(self)
    end

    def self.limit
      self
    end

  end
end

module ActiveRecord
  class Relation
  end
end
