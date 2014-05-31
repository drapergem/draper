module Draper
  require 'active_support/test_case'

  class TestCase < ::ActiveSupport::TestCase
    module ViewContextTeardown
      def teardown
        super
        Draper::ViewContext.clear!
      end
    end

    module Behavior
      if defined?(::Devise)
        require 'draper/test/devise_helper'
        include Draper::DeviseHelper
      end

      if defined?(::Capybara) && (defined?(::RSpec) || defined?(::MiniTest::Matchers))
        require 'capybara/rspec/matchers'
        include ::Capybara::RSpecMatchers
      end

      include Draper::ViewHelpers::ClassMethods
      alias_method :helper, :helpers
    end

    include Behavior
    include ViewContextTeardown
  end
end

if defined?(ActionController::TestCase)
  class ActionController::TestCase
    include Draper::TestCase::ViewContextTeardown
  end
end

if defined?(ActionMailer::TestCase)
  class ActionMailer::TestCase
    include Draper::TestCase::ViewContextTeardown
  end
end
