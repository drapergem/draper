module Draper
  class System
    def self.setup
      ActionController::Base.send(:include, Draper::ViewContextFilter) if defined?(ActionController::Base)
      ActionMailer::Base.send(:include, Draper::ViewContextFilter) if defined?(ActionMailer::Base)
    end
  end
end
