require 'spec_helper'

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
    Thread.current[:current_view_context] = nil
    expect {app_controller.current_view_context}.should raise_exception(Exception)
  end
end
