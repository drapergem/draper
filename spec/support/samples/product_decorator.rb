class ProductDecorator < Draper::Base
  decorates :product

  def awesome_title
    "Awesome Title"
  end
end
