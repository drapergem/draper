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

    def default_query_methods_strategy
      @@default_query_methods_strategy ||= :active_record
    end

    def default_query_methods_strategy=(strategy)
      @@default_query_methods_strategy = strategy
    end
  end
end
