class Product < ActiveRecord::Base
  def self.find(id)
    return Product.new
  end
  
  def hello_world
    "Hello, World"
  end
  
  def goodnight_moon
    "Goodnight, Moon"
  end
  
  def title
    "Sample Title"
  end
  
  def block
    yield
  end
end