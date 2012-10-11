module Draper
  module ActiveModelSupport
    def to_model
      self
    end

    def to_param
      model.to_param
    end
  end
end
