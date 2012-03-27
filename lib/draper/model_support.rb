module Draper::ModelSupport
  extend ActiveSupport::Concern

  def decorator(options = {})
    @decorator ||= "#{self.class.name}Decorator".constantize.decorate(self, options.merge(:infer => false))
    block_given? ? yield(@decorator) : @decorator
  end

  alias :decorate :decorator

  module ClassMethods
    def decorate(options = {})
      decorator_proxy = "#{model_name}Decorator".constantize.decorate(self.scoped, options)
      block_given? ? yield(decorator_proxy) : decorator_proxy
    end
  end
end
