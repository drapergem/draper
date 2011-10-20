module Draper
  class System    
    def self.setup
      ActionController::Base.send(:include, Draper::ViewContextFilter) if defined?(ActionController::Base)
    end
  end
end