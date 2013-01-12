require 'bundler/setup'
require 'ammeter/init'
require 'rails'

require 'action_view'
require 'action_controller'
require 'action_controller/test_case'

Bundler.require

require 'support/active_model'
require 'support/active_record'
require 'support/action_controller'

require 'support/models/product'
require 'support/models/namespaced_product'
require 'support/models/non_active_model_product'
require 'support/models/widget'
require 'support/models/some_thing'
require 'support/models/uninferrable_decorator_model'

require 'support/decorators/product_decorator'
require 'support/decorators/namespaced_product_decorator'
require 'support/decorators/non_active_model_product_decorator'
require 'support/decorators/widget_decorator'
require 'support/decorators/specific_product_decorator'
require 'support/decorators/products_decorator'
require 'support/decorators/some_thing_decorator'
require 'support/decorators/decorator_with_application_helper'

class << Rails
  undef application # Avoid silly Rails bug: https://github.com/rails/rails/pull/6429
end
