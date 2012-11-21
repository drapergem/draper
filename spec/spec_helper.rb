require 'bundler/setup'
require 'ammeter/init'
require 'rails'

require 'action_view'
require 'action_controller'
require 'action_controller/test_case'

Bundler.require

require './spec/support/active_model'
require './spec/support/active_record'
require './spec/support/action_controller'

require './spec/support/models/product'
require './spec/support/models/namespaced_product'
require './spec/support/models/non_active_model_product'
require './spec/support/models/widget'
require './spec/support/models/some_thing'
require './spec/support/models/uninferrable_decorator_model'

require './spec/support/decorators/product_decorator'
require './spec/support/decorators/namespaced_product_decorator'
require './spec/support/decorators/non_active_model_product_decorator'
require './spec/support/decorators/widget_decorator'
require './spec/support/decorators/specific_product_decorator'
require './spec/support/decorators/products_decorator'
require './spec/support/decorators/some_thing_decorator'
require './spec/support/decorators/decorator_with_application_helper'

class << Rails
  undef application # Avoid silly Rails bug: https://github.com/rails/rails/pull/6429
end
