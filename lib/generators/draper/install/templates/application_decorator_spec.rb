require 'spec_helper'

describe ApplicationDecorator do
  before { ApplicationController.new.set_current_view_context }
end
