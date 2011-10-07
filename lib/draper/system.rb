module Draper
  class System
    def self.setup
      ActionController::Base.prepend_before_filter do
        Draper::Base.helper = self.view_context_class.new(nil, {}, self)
      end if defined?(ActionController::Base)
    end
  end
end
