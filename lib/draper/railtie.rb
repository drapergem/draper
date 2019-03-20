require 'rails/railtie'

module ActiveModel
  class Railtie < Rails::Railtie
    generators do |app|
      Rails::Generators.configure! app.config.generators
      require_relative '../generators/controller_override'
    end
  end
end

module Draper
  class Railtie < Rails::Railtie
    config.after_initialize do |app|
      app.config.paths.add 'app/decorators', eager_load: true

      if Rails.env.test?
        require 'draper/test_case'
        require 'draper/test/rspec_integration' if defined?(RSpec) and RSpec.respond_to?(:configure)
      end
    end

    initializer 'draper.setup_action_controller' do
      ActiveSupport.on_load :action_controller do
        Draper.setup_action_controller self
      end
    end

    initializer 'draper.setup_action_mailer' do
      ActiveSupport.on_load :action_mailer do
        Draper.setup_action_mailer self
      end
    end

    initializer 'draper.setup_orm' do
      [:active_record, :mongoid].each do |orm|
        ActiveSupport.on_load orm do
          Draper.setup_orm self
        end
      end
    end

    initializer 'draper.minitest-rails_integration' do
      ActiveSupport.on_load :minitest do
        require 'draper/test/minitest_integration'
      end
    end

    def initialize_view_context
      require 'action_controller/test_case'
      Draper.default_controller.new.view_context
      Draper::ViewContext.build
    end

    console { initialize_view_context }

    runner { initialize_view_context }

    rake_tasks { Dir[File.join(File.dirname(__FILE__), 'tasks/*.rake')].each { |f| load f } }
  end
end
