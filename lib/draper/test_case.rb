module Draper
  require 'active_support/test_case'

  class TestCase < ::ActiveSupport::TestCase
    module ViewContextTeardown
      def before_setup
        Draper::ViewContext.clear!
        super
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
      alias :helper :helpers
    end

    include Behavior
    include ViewContextTeardown
  end
end

if defined? ActionController::TestCase
  ActionController::TestCase.include Draper::TestCase::ViewContextTeardown
end

if defined? ActionMailer::TestCase
  ActionMailer::TestCase.include Draper::TestCase::ViewContextTeardown
end
