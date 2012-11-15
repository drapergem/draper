require 'rails/railtie'

module ActiveModel
  class Railtie < Rails::Railtie
    generators do |app|
      Rails::Generators.configure! app.config.generators
      require 'generators/resource_override'
    end
  end
end

module Draper
  class Railtie < Rails::Railtie

    config.after_initialize do |app|
      app.config.paths.add 'app/decorators', eager_load: true
    end

    initializer "draper.setup_action_controller" do |app|
      ActiveSupport.on_load :action_controller do
        Draper.setup_action_controller self
      end
    end

    initializer "draper.setup_action_mailer" do |app|
      ActiveSupport.on_load :action_mailer do
        Draper.setup_action_mailer self
      end
    end

    initializer "draper.setup_active_record" do |app|
      ActiveSupport.on_load :active_record do
        Draper.setup_active_record self
      end
    end

    console do
      require 'action_controller/test_case'
      ApplicationController.new.view_context
      Draper::ViewContext.build_view_context
    end

  end
end
