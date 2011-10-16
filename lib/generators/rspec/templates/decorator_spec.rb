require 'spec_helper'

describe <%= singular_name.camelize %>Decorator do
  before { ApplicationController.new.set_current_view_context }
end
