module Draper
  module ViewContext
    def self.current
      Thread.current[:current_view_context]
    end

    def self.current=(input)
      Thread.current[:current_view_context] = input
    end
  end
end
