require 'rubygems'
require 'bundler/setup'
Bundler.require

require './spec/support/samples/active_record.rb'
require './spec/support/samples/application_controller.rb'
require './spec/support/samples/application_helper.rb'
require './spec/support/samples/decorator.rb'
require './spec/support/samples/decorator_with_allows.rb'
require './spec/support/samples/decorator_with_application_helper.rb'
require './spec/support/samples/decorator_with_denies.rb'
require './spec/support/samples/namespaced_product.rb'
require './spec/support/samples/namespaced_product_decorator.rb'
require './spec/support/samples/product.rb'
require './spec/support/samples/product_decorator.rb'
require './spec/support/samples/specific_product_decorator.rb'
require './spec/support/samples/widget.rb'
require './spec/support/samples/widget_decorator.rb'
