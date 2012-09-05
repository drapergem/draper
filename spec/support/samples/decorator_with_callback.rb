class DecoratorWithCallback < Draper::Base

  attr_accessor :test

  def on_create
    @test = "Yay I'm a callback"
  end
  
end
