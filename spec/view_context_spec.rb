require 'spec_helper'
require 'draper'

describe Draper::ViewContext do
  let (:app_controller) do
    ApplicationController
  end
  
  let (:app_controller_instance) do
    app_controller.new
  end
  
  it "implements .current_view_context" do
    app_controller.should respond_to(:current_view_context)
  end
  
  it "implements #set_current_view_context" do
    app_controller_instance.should respond_to(:set_current_view_context)
  end
  
  it "sets and returns the view context" do
    fake_context = Object.new
    Thread.current[:current_view_context] = nil
    app_controller_instance.class.send(:view_context=, fake_context)
    app_controller_instance.set_current_view_context
    app_controller.current_view_context.should === fake_context
  end
  
  it "calls #before_filter with #set_current_view_context" do
    app_controller.before_filters.should include(:set_current_view_context)
  end
  
  it "raises an exception if the view_context is fetched without being set" do
    Thread.current[:current_view_context] = nil
    expect {app_controller.current_view_context}.should raise_exception(Exception)
  end
end