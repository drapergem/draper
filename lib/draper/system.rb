module Draper
  class System    
    def self.setup
      ActionController::Base.send(:include, Draper::ViewContext) if defined?(ActionController::Base)
    end
  end
end