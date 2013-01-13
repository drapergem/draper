module Draper
  module DecoratorExampleGroup
    include Draper::TestCase::Behavior
    extend ActiveSupport::Concern

    included { metadata[:type] = :decorator }
  end

  RSpec.configure do |config|
    config.include DecoratorExampleGroup, example_group: {file_path: %r{spec/decorators}}, type: :decorator
  end
end
