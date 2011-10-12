module Drapper
  class System    
    def self.setup
      ActionController::Base.send(:include, Drapper::ViewContext) if defined?(ActionController::Base)
    end
  end
end
