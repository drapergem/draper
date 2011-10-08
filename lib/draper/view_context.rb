module Draper
  module ViewContext
    module ClassMethods
      def current_view_context
        Thread.current[:current_view_context] || 
          raise("set_current_view_context must be called from a before_filter")
      end
    end
    
    module InstanceMethods
      def set_current_view_context
        Thread.current[:current_view_context] ||= self.class.view_context
      end
    end
    
    def self.included(source)
      source.send(:include, InstanceMethods)
      source.send(:extend, ClassMethods)
      source.send(:before_filter, :set_current_view_context)
    end
  end
end