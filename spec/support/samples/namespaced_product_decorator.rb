require './spec/support/samples/product'

module Namespace
  class ProductDecorator < Draper::Base
    decorates :product, :class => Namespace::Product
  end
end
