require 'minitest/rails/active_support'

module Draper
  module MiniTest

    class DecoratorTestCase < ::MiniTest::Rails::ActiveSupport::TestCase
      include Draper::ViewHelpers::ClassMethods
      alias_method :helper, :helpers

      register_spec_type(self) do |desc|
        desc < Draper::Decorator if desc.is_a?(Class)
      end
      register_spec_type(/Decorator( ?Test)?\z/i, self)
    end

    class Railtie < Rails::Railtie
      config.after_initialize do |app|
        if defined?(Capybara)
          require 'capybara/rspec/matchers'
          DecoratorTestCase.send :include, Capybara::RSpecMatchers
        end

        if defined?(Devise)
          require 'draper/test/devise_helper'
          DecoratorTestCase.send :include, Draper::DeviseHelper
        end
      end
    end
  end

end
