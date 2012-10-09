module Draper
  module ViewContext
    def self.current_controller
      Thread.current[:current_controller] || ApplicationController.new
    end

    def self.current_controller=(controller)
      Thread.current[:current_controller] = controller
    end

    def self.current
      Thread.current[:current_view_context] ||= build_view_context
    end

    def self.current=(context)
      Thread.current[:current_view_context] = context
    end

    def view_context
      super.tap do |context|
        Draper::ViewContext.current = context
      end
    end

    private

    def self.build_view_context
      current_controller.view_context.tap do |context|
        context.instance_eval do
          def url_options
            ActionMailer::Base.default_url_options
          end
        end unless context.request
        if defined?(ActionController::TestRequest)
          context.controller.request ||= ActionController::TestRequest.new
          context.request            ||= context.controller.request
          context.params             ||= {}
        end
      end
    end
  end
end
