require 'rails/railtie'

module ActiveModel
  class Railtie < Rails::Railtie
    generators do |app|
      Rails::Generators.configure!(app.config.generators)
      require "generators/resource_override"
    end
  end
end

module Draper
  class Railtie < Rails::Railtie

    ##
    # The `app/decorators` path is eager loaded
    #
    # This is the standard "Rails Way" to add paths from which constants
    # can be loaded.
    #
    config.after_initialize do |app|
      app.config.paths.add 'app/decorators', :eager_load => true
    end

    initializer "draper.extend_action_controller_base" do |app|
      ActiveSupport.on_load(:action_controller) do
        Draper::System.setup_action_controller(self)
      end
    end

    initializer "draper.extend_action_mailer_base" do |app|
      ActiveSupport.on_load(:action_mailer) do
        Draper::System.setup_action_mailer(self)
      end
    end

    initializer "draper.extend_active_record_base" do |app|
      ActiveSupport.on_load(:active_record) do
        self.send(:include, Draper::ModelSupport)
      end
    end

    console do
      require 'action_controller/test_case'
      ApplicationController.new.view_context
      Draper::ViewContext.current.controller.request ||= ActionController::TestRequest.new
      Draper::ViewContext.current.request            ||= Draper::ViewContext.current.controller.request
      Draper::ViewContext.current.params             ||= {}
    end
  end
end
