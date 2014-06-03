module Draper
  module DecoratorExampleGroup
    include Draper::TestCase::Behavior
    extend ActiveSupport::Concern

    included { metadata[:type] = :decorator }
  end

  RSpec.configure do |config|
    if RSpec::Core::Version::STRING.starts_with?("3")
      config.include DecoratorExampleGroup, file_path: %r{spec/decorators}, type: :decorator
    else
      config.include DecoratorExampleGroup, example_group: {file_path: %r{spec/decorators}}, type: :decorator
    end

    [:decorator, :controller, :mailer].each do |type|
      config.before(:each, type: type) { Draper::ViewContext.clear! }
    end
  end
end
