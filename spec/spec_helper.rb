require 'bundler/setup'
require 'ammeter/init'
require 'rails'

require 'action_view'
Bundler.require

require './spec/support/samples/active_record'
require './spec/support/samples/decorator'
require './spec/support/samples/decorator_with_application_helper'
require './spec/support/samples/decorator_with_special_methods'
require './spec/support/samples/finder_decorator'
require './spec/support/samples/namespaced_product'
require './spec/support/samples/namespaced_product_decorator'
require './spec/support/samples/non_active_model_product'
require './spec/support/samples/non_active_model_product_decorator'
require './spec/support/samples/product'
require './spec/support/samples/product_decorator'
require './spec/support/samples/products_decorator'
require './spec/support/samples/sequel_product'
require './spec/support/samples/specific_product_decorator'
require './spec/support/samples/some_thing'
require './spec/support/samples/some_thing_decorator'
require './spec/support/samples/uninferrable_decorator_model'
require './spec/support/samples/widget'
require './spec/support/samples/widget_decorator'

require 'action_controller'
require 'action_controller/test_case'

module ActionController
  class Base
    Draper::System.setup_action_controller(self)
  end
end

module ActiveRecord
  class Relation
  end
end

class ApplicationController < ActionController::Base
  def hello_world
    "Hello, World!"
  end
  helper_method :hello_world
end


class << Rails
  undef application # Avoid silly Rails bug: https://github.com/rails/rails/pull/6429
end
