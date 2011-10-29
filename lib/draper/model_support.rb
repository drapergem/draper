module Draper::ModelSupport
  def decorator
    @decorator ||= "#{self.class.name}Decorator".constantize.decorate(self)
    block_given? ? yield(@decorator) : @decorator
  end

  module ClassMethods
    def decorate(context = {})
      @decorator_proxy ||= "#{model_name}Decorator".constantize.decorate(self.scoped)
      block_given? ? yield(@decorator_proxy) : @decorator_proxy
    end
  end

  def self.included(base)
    base.extend(ClassMethods)
  end
end
