require 'test_helper'

class <%= class_name %>DecoratorTest < ActiveSupport::TestCase
  def setup
    ApplicationController.new.view_context
  end
end
