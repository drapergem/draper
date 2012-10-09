class DecoratorWithSpecialMethods < Draper::Decorator
  def to_param
    "foo"
  end

  def id
    1337
  end

  def errors
    ["omg errors!"]
  end
end
