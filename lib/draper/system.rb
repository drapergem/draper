module Draper
  class System
    def self.setup
      ActionController::Base.prepend_before_filter do
        Draper::Base.helper.setup(self)
      end if defined?(ActionController::Base)
    end
  end
end
