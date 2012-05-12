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
    # Decorators are loaded in
    # => at app boot in non-development environments
    # => after each request in the development environment
    #
    # This is necessary because we might never explicitly reference
    # Decorator constants.
    #
    config.to_prepare do
      ::Draper::System.load_app_local_decorators
    end

    ##
    # The `app/decorators` path is eager loaded
    #
    # This is the standard "Rails Way" to add paths from which constants
    # can be loaded.
    #
    config.before_initialize do |app|
      app.config.paths.add 'app/decorators', :eager_load => true
    end

    initializer "draper.extend_action_controller_base" do |app|
      ActiveSupport.on_load(:action_controller) do
        Draper::System.setup(:action_controller)
      end
    end

    initializer "draper.extend_action_mailer_base" do |app|
      ActiveSupport.on_load(:action_mailer) do
        Draper::System.setup(:action_mailer)
      end
    end

    console do
      require 'action_controller/test_case'
      ApplicationController.new.set_current_view_context
      Draper::ViewContext.current.controller.request ||= ActionController::TestRequest.new
      Draper::ViewContext.current.request            ||= Draper::ViewContext.current.controller.request
      Draper::ViewContext.current.params             ||= {}
    end
  end
end
