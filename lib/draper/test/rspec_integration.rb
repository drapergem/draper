module Draper
  module RSpec

    module DecoratorExampleGroup
      extend ActiveSupport::Concern
      included { metadata[:type] = :decorator }

      include Draper::ViewHelpers::ClassMethods
      alias_method :helper, :helpers
    end

    ::RSpec.configure do |config|
      # Automatically tag specs in specs/decorators as type: :decorator
      config.include DecoratorExampleGroup, :type => :decorator, :example_group => {
        :file_path => %r{spec/decorators}
      }
    end

    class Railtie < Rails::Railtie
      config.after_initialize do |app|
        ::RSpec.configure do |rspec|
          if defined?(Capybara)
            require 'capybara/rspec/matchers'
            rspec.include Capybara::RSpecMatchers, :type => :decorator
          end

          if defined?(Devise)
            require 'draper/test/devise_helper'
            rspec.include Draper::DeviseHelper, :type => :decorator
          end
        end
      end
    end

  end
end

