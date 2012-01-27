module Draper::ModelSupport
  def decorator(options = {})
    @decorator ||= "#{self.class.name}Decorator".constantize.decorate(self, options.merge(:infer => false))
    block_given? ? yield(@decorator) : @decorator
  end

  alias :decorate :decorator

  module ClassMethods
    def decorate(options = {})
      @decorator_proxy = __decorator_proxy__(options)
      block_given? ? yield(@decorator_proxy) : @decorator_proxy
    end

  private

    def __decorator_proxy__(options)
      "#{model_name}Decorator".constantize.decorate(__object_to_decorate__, options)
    end

    def __object_to_decorate__
      self.respond_to?(:each) ? self : self.scoped
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
  end
end
