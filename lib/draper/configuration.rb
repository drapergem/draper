module Draper
  module Configuration
    def configure
      yield self
    end

    def default_controller
      @@default_controller ||= ApplicationController
    end

    def default_controller=(controller)
      @@default_controller = controller
    end
  end
end
