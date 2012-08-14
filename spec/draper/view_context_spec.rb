require 'spec_helper'
require 'draper/test/view_context'

describe Draper::ViewContext do
  before(:each) do
    Thread.current[:current_view_context] = nil
  end

  let(:app_controller) { ApplicationController }
  let(:app_controller_instance) { app_controller.new }

  it "provides a method to create a view context while testing" do
    Draper::ViewContext.should respond_to(:infect!)
  end

  it "copies the controller's view context to draper" do
    ctx = app_controller_instance.view_context
    Draper::ViewContext.current.should == ctx
  end

  describe "view_context priming" do
    let(:app_controller_instance) { double(ApplicationController, :view_context => view_context) }
    let(:view_context) { double("ApplicationController#view_context") }

    it "primes the view_context when nil" do
      app_controller.should_receive(:new).and_return(app_controller_instance)
      Draper::ViewContext.current.should == view_context
    end
  end
end
