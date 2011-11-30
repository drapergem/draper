module Draper::ModelSupport
  def decorator(options = {})
    @decorator ||= "#{self.class.name}Decorator".constantize.decorate(self, options)
    block_given? ? yield(@decorator) : @decorator
  end
  
  alias :decorate :decorator

  module ClassMethods
    def decorate(options = {})
      @decorator_proxy ||= "#{model_name}Decorator".constantize.decorate(self.scoped, options)
      block_given? ? yield(@decorator_proxy) : @decorator_proxy
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
  end
end
