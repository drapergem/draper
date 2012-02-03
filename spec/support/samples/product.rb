class Product < ActiveRecord::Base
  include Draper::ModelSupport

  def self.find_by_name(name)
    @@dummy ||= Product.new
  end

  def self.first
    @@first ||= Product.new
  end

  def self.last
    @@last ||= Product.new
  end

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

  def some_action
    self.nonexistant_method
  end

  def block
    yield
  end

  def self.reflect_on_association(association_symbol)
    OpenStruct.new(:klass => self)
  end

  def similar_products
    [Product.new, Product.new]
  end

  def previous_version
    Product.new
  end
end
