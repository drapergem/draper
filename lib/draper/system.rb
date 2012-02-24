module Draper
  class System
    def self.setup(component)
      if component == :action_controller
        ActionController::Base.send(:include, Draper::ViewContextFilter)
        ActionController::Base.extend(Draper::HelperSupport)
      elsif component == :action_mailer
        ActionMailer::Base.send(:include, Draper::ViewContextFilter)
      end
    end
  end
end
