module Draper
  class System    
    def self.setup
      ActionController::Base.send(:extend, Draper::AllHelpers) if defined?(ActionController::Base)
    end
  end
end