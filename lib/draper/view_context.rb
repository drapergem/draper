module Draper
  module ViewContext
    def self.current
      context = Thread.current[:current_view_context]
      context ||= ApplicationController.new.view_context
      context.controller.request ||= ActionController::TestRequest.new
      context.request            ||= context.controller.request
      context.params             ||= {}
      Thread.current[:current_view_context] = context
      context
    end

    def self.current=(input)
      Thread.current[:current_view_context] = input
    end

    def view_context
      super.tap do |context|
        Draper::ViewContext.current = context
      end
    end
  end
end
