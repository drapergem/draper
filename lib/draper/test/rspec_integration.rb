require 'draper/test/view_context'

module Draper
  module DecoratorExampleGroup
    extend ActiveSupport::Concern
    included { metadata[:type] = :decorator }
  end
end

RSpec.configure do |config|
  # Automatically tag specs in specs/decorators as type: :decorator
  config.include Draper::DecoratorExampleGroup, :type => :decorator, :example_group => {
    :file_path => /spec[\\\/]decorators/
  }

  # Specs tagged type: :decorator set the Draper view context
  config.before :type => :decorator do
    ApplicationController.new.set_current_view_context
    Draper::ViewContext.current.controller.request ||= ActionController::TestRequest.new
    Draper::ViewContext.current.request            ||= Draper::ViewContext.current.controller.request
    Draper::ViewContext.current.params             ||= {}
  end

  config.before :type => :view do
    controller.set_current_view_context
  end
end

if defined?(Capybara)
  require 'capybara/rspec/matchers'

  RSpec.configure do |config|
    config.include Capybara::RSpecMatchers, :type => :decorator
  end
end

