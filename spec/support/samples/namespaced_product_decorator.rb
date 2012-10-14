require './spec/support/samples/namespaced_product'

module Namespace
  class ProductDecorator < Draper::Decorator
    add_finders
  end
end
