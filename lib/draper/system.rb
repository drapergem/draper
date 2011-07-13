module Draper
  class System    
    def self.setup
      ActionController::Base.send(:extend, Draper::AllHelpers)
    end
  end
end