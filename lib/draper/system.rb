module Draper
  class System
    def self.app_local_decorator_glob
      'app/decorators/**/*_decorator.rb'
    end

    def self.load_app_local_decorators
      decorator_files = Dir[ "#{ Rails.root }/#{ app_local_decorator_glob }" ]
      decorator_files.each { |d| require_dependency d }
    end

    def self.setup(component)
      component.class_eval do
        include Draper::ViewContextFilter
        extend  Draper::HelperSupport unless defined?(::ActionMailer) && self.is_a?(::ActionMailer::Base)
      end
    end
  end
end
