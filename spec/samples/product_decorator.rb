class Product
  def self.find(id)
    return Product.new
  end
  
  def hello_world
    "Hello, World"
  end
  
  def block
    yield
  end
end

class ProductDecorator < Draper::Base
  decorates :product
end
