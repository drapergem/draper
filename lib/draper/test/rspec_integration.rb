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

end

if defined?(Capybara)
  require 'capybara/rspec/matchers'

  RSpec.configure do |config|
    config.include Capybara::RSpecMatchers, :type => :decorator
  end
end
