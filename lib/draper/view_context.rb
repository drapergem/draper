module Draper
  module ViewContext
    def self.current
      Thread.current[:current_view_context] || ApplicationController.new.view_context
    end

    def self.current=(input)
      Thread.current[:current_view_context] = input
    end

    def view_context
      super.tap do |context|
        Draper::ViewContext.current = context
      end
    end
  end
end
