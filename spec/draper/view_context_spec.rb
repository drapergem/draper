require 'spec_helper'
require 'draper/test/view_context'

describe Draper::ViewContext do
  let(:app_controller) { ApplicationController }
  let(:app_controller_instance) { app_controller.new }

  it "provides a method to create a view context while testing" do
    Draper::ViewContext.should respond_to(:infect!)
  end
end
