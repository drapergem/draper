module ActionController
  class Base
    @@before_filters = []
    def self.before_filters
      @@before_filters
    end
    def self.before_filter(name)
      @@before_filters << name
    end
  end
end

class ApplicationController < ActionController::Base
  extend ActionView::Helpers
  extend ActionView::Helpers::TagHelper
  extend ActionView::Helpers::UrlHelper
  extend ApplicationHelper    
  
  def view_context
    @view_context ||= ApplicationController
  end
  
  def view_context=(input)
    @view_context = input
  end
  
  def self.hello
    "Hello!"
  end
end

Draper::System.setup