module Draper
  class System
    def self.app_local_decorator_glob
      'app/decorators/**/*_decorator.rb'
    end

    def self.load_app_local_decorators
      decorator_files = Dir[ "#{ Rails.root }/#{ app_local_decorator_glob }" ]
      decorator_files.each { |d| load d }
    end

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
