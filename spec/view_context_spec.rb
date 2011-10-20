require 'spec_helper'
require 'draper'

describe Draper::ViewContext do
  let (:app_controller) do
    ApplicationController
  end
  
  let (:app_controller_instance) do
    app_controller.new
  end
  
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
  
  it "sets view_context every time" do
    app_controller_instance.stub(:view_context) { 'first' }
    app_controller_instance.set_current_view_context
    Draper::ViewContext.current.should == 'first'
    
    app_controller_instance.stub(:view_context) { 'second' }
    app_controller_instance.set_current_view_context
    Draper::ViewContext.current.should == 'second'
  end
end