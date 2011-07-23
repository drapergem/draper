class Product
  def self.find(id)
    return Product.new
  end
end

class ProductDecorator < Draper::Base
  decorates :product
end
