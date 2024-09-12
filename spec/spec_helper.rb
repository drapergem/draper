require 'simplecov'
SimpleCov.start do
  add_filter 'spec'
  add_group 'Draper', 'lib/draper'
  add_group 'Generators', 'lib/generators'
end

require 'bundler/setup'
require 'draper'
require 'action_controller'
require 'action_controller/test_case'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.yield_receiver_to_any_instance_implementation_blocks = true
  end

  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.disable_monkey_patching!

  if config.files_to_run.one?
    config.default_formatter = 'doc'
  else
    config.default_formatter = 'progress'
  end

  config.order = :random
  Kernel.srand config.seed
end

class Model; include Draper::Decoratable; end

class Product < Model; end
class SpecialProduct < Product; end
class Other < Model; end
class Person < Model; end
class Child < Person; end
class ProductDecorator < Draper::Decorator; end
class ProductsDecorator < Draper::CollectionDecorator; end

class OtherDecorator < Draper::Decorator; end

module Namespaced
  class Product < Model; end
  class ProductDecorator < Draper::Decorator; end
  ProductsDecorator = Class.new(Draper::CollectionDecorator)
  class OtherDecorator < Draper::Decorator; end
end

ApplicationController = Class.new(ActionController::Base)
CustomController = Class.new(ActionController::Base)

# After each example, revert changes made to the class
def protect_class(klass)
  before { stub_const klass.name, Class.new(klass) }
end

def protect_module(mod)
  before { stub_const mod.name, mod.dup }
end
