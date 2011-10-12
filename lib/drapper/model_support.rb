module Drapper::ModelSupport
  def decorator
    @decorator ||= "#{self.class.name}Decorator".constantize.decorate(self)
    block_given? ? yield(@decorator) : @decorator
  end
end
