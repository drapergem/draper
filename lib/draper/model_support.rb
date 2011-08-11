module Draper::ModelSupport
  def decorator
    @decorator ||= "#{self.class.name}Decorator".constantize.decorate(self)
  end
end
