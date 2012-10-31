require './spec/support/samples/namespaced_product'

module Namespace
  class ProductDecorator < Draper::Decorator
    has_finders
  end
end
