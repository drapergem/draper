require './spec/support/samples/application_helper'

module ActionController
  class AbstractController
    def view_context
      @view_context ||= ApplicationController
    end

    def view_context=(input)
      @view_context = input
    end
  end
  class Base < AbstractController
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

  def self.hello
    "Hello!"
  end

  def self.capture(&block)
    @@capture = true
    block.call
  end

  def self.capture_triggered
    @@capture ||= false
  end
end
