require "./performance/active_record"
class Product < ActiveRecord::Base
  def self.sample_class_method
    "sample class method"
  end

  def hello_world
    "Hello, World"
  end
end

class FastProduct < ActiveRecord::Base
  def self.sample_class_method
    "sample class method"
  end

  def hello_world
    "Hello, World"
  end
end
