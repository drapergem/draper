class CategoryDecorator < Draper::Decorator
  decorates_association :item

  def item_name
    item.name
  end
end