require 'spec_helper'
require 'draper/test/view_context'

describe Draper::ViewContext do
  let(:app_controller) { ApplicationController }
  let(:app_controller_instance) { app_controller.new }

  it "implements #set_current_view_context" do
    app_controller_instance.should respond_to(:set_current_view_context)
  end

  it "calls #before_filter with #set_current_view_context" do
    app_controller.before_filters.should include(:set_current_view_context)
  end

  it "raises an exception if the view_context is fetched without being set" do
    Draper::ViewContext.current = nil
    expect {app_controller.current_view_context}.should raise_exception(Exception)
  end

  it "provides a method to create a view context while testing" do
    Draper::ViewContext.should respond_to(:infect!)
  end
end
