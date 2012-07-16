module Draper
  module ViewContext
    def self.infect!(context)
      context.instance_eval do
        ApplicationController.new.view_context
        Draper::ViewContext.current.controller.request ||= ActionController::TestRequest.new
        Draper::ViewContext.current.request            ||= Draper::ViewContext.current.controller.request
        Draper::ViewContext.current.params             ||= {}
      end
    end
  end
end
