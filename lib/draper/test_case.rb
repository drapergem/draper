module Draper
  begin
    require 'minitest/rails'
  rescue LoadError
  end

  active_support_test_case = begin
    require 'minitest/rails/active_support' # minitest-rails < 0.5
    ::MiniTest::Rails::ActiveSupport::TestCase
  rescue LoadError
    require 'active_support/test_case'
    ::ActiveSupport::TestCase
  end

  class TestCase < active_support_test_case
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
