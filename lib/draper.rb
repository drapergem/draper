require 'action_view'

require 'draper/version'
require 'draper/system'
require 'draper/view_helpers'
require 'draper/finders'
require 'draper/decorator'
require 'draper/helper_proxy'
require 'draper/lazy_helpers'
require 'draper/decoratable'
require 'draper/security'
require 'draper/helper_support'
require 'draper/view_context'
require 'draper/collection_decorator'
require 'draper/railtie' if defined?(Rails)

# Test Support
require 'draper/test/rspec_integration'    if defined?(RSpec) and RSpec.respond_to?(:configure)
require 'draper/test/minitest_integration' if defined?(MiniTest::Rails)

module Draper
  class UninferrableDecoratorError < NameError
    def initialize(klass)
      super("Could not infer a decorator for #{klass}.")
    end
  end
end
