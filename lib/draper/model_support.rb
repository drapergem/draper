module Draper::ModelSupport
  extend ActiveSupport::Concern

  def decorator(options = {})
    @decorator ||= begin
      if options[:infer]
        decorator_class = "#{self.class.name}Decorator".constantize
      else
        decorator_version = options[:version] || :default
        decorator_class = self.class.registered_decorators[decorator_version].constantize
      end
      decorator_class.decorate(self, options.merge(:infer => false))
    end
    block_given? ? yield(@decorator) : @decorator
  end

  alias :decorate :decorator

  module ClassMethods
    def decorate(options = {})
      @decorator_proxy ||= begin
        if options[:infer]
          decorator_class = "#{self.name}Decorator".constantize
        else
          decorator_version = options[:version] || :default
          decorator_class = self.registered_decorators[decorator_version].constantize
        end
        decorator_class.decorate(self.scoped, options)
      end
      block_given? ? yield(@decorator_proxy) : @decorator_proxy
    end
  end

end
