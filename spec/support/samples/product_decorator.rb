class ProductDecorator < Draper::Decorator
  has_finders

  def awesome_title
    "Awesome Title"
  end

  def self.my_class_method
  end
end
