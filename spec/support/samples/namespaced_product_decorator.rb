require './spec/support/samples/namespaced_product'

module Namespace
  class ProductDecorator < Draper::Decorator
    decorates :product, :class => Namespace::Product
  end
end
