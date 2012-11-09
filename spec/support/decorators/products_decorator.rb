class ProductsDecorator < Draper::CollectionDecorator

  def link_to
    h.link_to 'sample', "#"
  end

  def some_method
    "some method works"
  end
end
