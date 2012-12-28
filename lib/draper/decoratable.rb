module Draper::Decoratable
  extend ActiveSupport::Concern

  def decorate(options = {})
    decorator_class.decorate(self, options)
  end

  def decorator_class
    self.class.decorator_class
  end

  def applied_decorators
    []
  end

  def decorated_with?(decorator_class)
    false
  end

  def decorated?
    false
  end

  def ==(other)
    super || (other.respond_to?(:source) && self == other.source)
  end

  module ClassMethods
    def decorate(options = {})
      decorator_class.decorate_collection(self.scoped, options)
    end

    def decorator_class
      prefix = respond_to?(:model_name) ? model_name : name
      "#{prefix}Decorator".constantize
    rescue NameError
      raise Draper::UninferrableDecoratorError.new(self)
    end

    def ===(other)
      super || (other.respond_to?(:source) && super(other.source))
    end
  end
end
