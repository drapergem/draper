module Draper
  class System
    def self.setup
      ActionController::Base.send(:include, Draper::ViewContextFilter) if defined?(ActionController::Base)
      ActionMailer::Base.send(:include, Draper::ViewContextFilter) if defined?(ActionMailer::Base)
      ActionController::Base.send(:helper, Draper::HelperSupport) if defined?(ActionController::Base)
    end
  end
end
