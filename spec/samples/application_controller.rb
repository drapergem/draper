class ApplicationController
  extend ActionView::Helpers
  extend ActionView::Helpers::TagHelper
  extend ActionView::Helpers::UrlHelper
  extend ApplicationHelper    
  
  def self.view_context
    @@view_context ||= ApplicationController
  end
  
  def self.view_context=(input)
    @@view_context = input
  end
  
  def self.hello
    "Hello!"
  end
  
  @@before_filters = []
  def self.before_filters
    @@before_filters
  end
  def self.before_filter(name)
    @@before_filters << name
  end
end

Draper::System.setup