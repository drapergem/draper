class ProductDecorator < Draper::Decorator
  has_finders

  def awesome_title
    "Awesome Title"
  end

  def overridable
    :overridden
  end

  def self.my_class_method
  end

  private

  def awesome_private_title
  end
end
