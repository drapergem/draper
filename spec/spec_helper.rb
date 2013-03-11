require 'bundler/setup'
require 'draper'
require 'rails/version'
require 'action_controller'
require 'action_controller/test_case'

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.expect_with(:rspec) {|c| c.syntax = :expect}
  config.order = :random
end

class Model; include Draper::Decoratable; end

class Product < Model; end
class ProductDecorator < Draper::Decorator; end
class ProductsDecorator < Draper::CollectionDecorator; end

class ProductPresenter < Draper::Decorator; end

class OtherDecorator < Draper::Decorator; end

module Namespaced
  class Product < Model; end
  class ProductDecorator < Draper::Decorator; end

  class OtherDecorator < Draper::Decorator; end
end

# After each example, revert changes made to the class
def protect_class(klass)
  before { stub_const klass.name, Class.new(klass) }
end

def protect_module(mod)
  before { stub_const mod.name, mod.dup }
end
