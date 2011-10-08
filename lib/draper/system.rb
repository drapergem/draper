module Draper
  class System    
    def self.setup
      ApplicationController.send(:include, Draper::ViewContext) if defined?(ApplicationController)
    end
  end
end