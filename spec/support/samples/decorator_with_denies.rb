class DecoratorWithDenies < Draper::Decorator
  denies :goodnight_moon, :title
end
