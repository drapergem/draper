module Draper
  module ViewContext
    def self.current
      Thread.current[:current_view_context] ||= build_view_context
    end

    def self.current=(input)
      Thread.current[:current_view_context] = input
    end

    private

    def self.build_view_context
      ApplicationController.new.view_context.tap do |context|
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

  module ViewContextFilter
    def view_context
      super.tap do |context|
        Draper::ViewContext.current = context
      end
    end
  end
end
