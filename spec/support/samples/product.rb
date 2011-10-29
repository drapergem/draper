class Product < ActiveRecord::Base
  include Draper::ModelSupport
  
  def self.all
    [Product.new, Product.new]
  end

  def self.scoped
    [Product.new]
  end

  def self.model_name
    "Product"
  end

  def self.find(id)
    return Product.new
  end
  
  def self.sample_class_method
    "sample class method"
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
