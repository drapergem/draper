module Draper::Decoratable
  extend ActiveSupport::Concern

  def decorator(options = {})
    @decorator ||= decorator_class.decorate(self, options.merge(:infer => false))
    block_given? ? yield(@decorator) : @decorator
  end

  def decorator_class
    "#{self.class.name}Decorator".constantize
  end

  alias :decorate :decorator

  def applied_decorators
    []
  end

  def decorated_with?(decorator_class)
    false
  end

  def decorated?
    false
  end

  module ClassMethods
    def decorate(options = {})
      decorator_proxy = decorator_class.decorate(self.scoped, options)
      block_given? ? yield(decorator_proxy) : decorator_proxy
    end

    def decorator_class
      "#{model_name}Decorator".constantize
    end
  end
end
