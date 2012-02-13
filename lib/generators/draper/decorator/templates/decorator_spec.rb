require 'spec_helper'

describe <%= resource_name.singularize.camelize %>Decorator do
  before { ApplicationController.new.set_current_view_context }
end
