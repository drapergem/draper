module Draper
  # @api private
  module Utils
    extend self

    # Returns an array of all decorator classes applied to an instance.
    def decorators_of(decorated_instance)
      decorators = []
      instance = decorated_instance
      while instance.kind_of?(Draper::Decorator)
        decorators << instance.class
        instance = instance.model
      end
      decorators
    end
  end
end
