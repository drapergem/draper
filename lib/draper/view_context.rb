module Draper
  module ViewContext
    def self.current
      Thread.current[:current_view_context].tap do |context|
        context ||= ApplicationController.new.view_context
        context.controller.request ||= ActionController::TestRequest.new
        context.request            ||= context.controller.request
        context.params             ||= {}
      end
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
