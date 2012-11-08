module Draper::Decoratable
  extend ActiveSupport::Concern

  def decorator(options = {})
    @decorator ||= decorator_class.decorate(self)
    block_given? ? yield(@decorator) : @decorator
  end
  alias_method :decorate, :decorator

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

  module ClassMethods
    def decorate(options = {})
      collection_decorator = decorator_class.decorate(self.scoped, options)
      block_given? ? yield(collection_decorator) : collection_decorator
    end

    def decorator_class
      prefix = respond_to?(:model_name) ? model_name : name
      "#{prefix}Decorator".constantize
    rescue NameError
      raise Draper::UninferrableDecoratorError.new(self)
    end
  end
end
