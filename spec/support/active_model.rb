module ActiveModel
  module Serialization
    def serializable_hash
      {overridable: send(:overridable)}
    end
  end
end
