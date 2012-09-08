module Draper
  module ViewContext
    def self.current
      Thread.current[:current_view_context] || ApplicationController.new.view_context
    end

    def self.current=(input)
      Thread.current[:current_view_context] = input
    end
  end

  module ViewContextFilter
    def view_context
      ApplicationController.new.view_context.tap do |context|
        Draper::ViewContext.current = self.view_context
      end
    end
  end
end
