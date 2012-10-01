module Draper
  class System
    def self.setup_action_controller(component)
      component.class_eval do
        include Draper::ViewContext
        extend  Draper::HelperSupport
        before_filter lambda {|controller|
          Draper::ViewContext.current = nil
          Draper::ViewContext.current_controller = controller
        }
      end
    end

    def self.setup_action_mailer(component)
      include Draper::ViewContext
    end
  end
end
