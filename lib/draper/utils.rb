module Draper
  module Utils
    extend self

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
