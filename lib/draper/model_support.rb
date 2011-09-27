module Draper::ModelSupport
  def decorator(context = {})
    @decorator ||= "#{self.class.name}Decorator".constantize.decorate(self, context)
    block_given? ? yield(@decorator) : @decorator
  end
end
