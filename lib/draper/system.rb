module Draper
  class System
    def self.setup(component)
      component.class_eval do
        include Draper::ViewContextFilter
        extend  Draper::HelperSupport unless defined?(::ActionMailer) && self.is_a?(::ActionMailer::Base)
      end
    end
  end
end
