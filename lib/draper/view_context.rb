module Draper
  module ViewContext
    def set_current_view_context
      Thread.current[:current_view_context] = self.view_context
    end
    
    def self.included(source)
      source.send(:before_filter, :set_current_view_context)
    end
  end
end