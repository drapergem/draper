class DecoratorApplicationHelper < Draper::Base  
  def uses_hello
    self.hello
  end
end
