module Draper::ArraySupport
  
  def decorate
    collect { |item| item.decorate if item.respond_to? :decorator_class }
  end
  
end
