class ProductDecorator < Draper::Decorator
  decorates :product

  def awesome_title
    "Awesome Title"
  end
end
