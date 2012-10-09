module Draper::ArraySupport
  
  def decorate
    collect { |item| item.respond_to? :decorator_class ? item.decorate : item }
  end
  
end
