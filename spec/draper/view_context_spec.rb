require 'spec_helper'
require 'draper/test/view_context'

describe Draper::ViewContext do
  let(:app_controller) { ApplicationController }
  let(:app_controller_instance) { app_controller.new }

  it "provides a method to create a view context while testing" do
    Draper::ViewContext.should respond_to(:infect!)
  end

  it "copies the controller's view context to draper" do
    ctx = app_controller_instance.view_context
    Draper::ViewContext.current.should == ctx
  end
end
