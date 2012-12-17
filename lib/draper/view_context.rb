require 'request_store'

module Draper
  module ViewContext
    def view_context
      super.tap do |context|
        Draper::ViewContext.current = context
      end
    end

    def self.current_controller
      RequestStore.store[:current_controller] || ApplicationController.new
    end

    def self.current_controller=(controller)
      RequestStore.store[:current_controller] = controller
    end

    def self.current
      RequestStore.store[:current_view_context] ||= build_view_context
    end

    def self.current=(context)
      RequestStore.store[:current_view_context] = context
    end

    def self.build_view_context
      current_controller.view_context.tap do |context|
        if defined?(ActionController::TestRequest)
          context.controller.request ||= ActionController::TestRequest.new
          context.request            ||= context.controller.request
          context.params             ||= {}
        end
      end
    end
  end
end
