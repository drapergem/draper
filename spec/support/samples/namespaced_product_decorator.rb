require './spec/support/samples/namespaced_product'

module Namespace
  class ProductDecorator < Draper::Base
    decorates :product, :class => Namespace::Product
  end
end
