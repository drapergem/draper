class ItemDecorator < Draper::Decorator
  def name
    "Item#{model.id}"
  end
end