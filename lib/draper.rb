require 'action_view'

require 'draper/version'
require 'draper/system'
require 'draper/active_model_support'
require 'draper/decorator'
require 'draper/lazy_helpers'
require 'draper/decoratable'
require 'draper/helper_support'
require 'draper/view_context'
require 'draper/collection_decorator'
require 'draper/railtie' if defined?(Rails)

# Test Support
require 'draper/test/rspec_integration'    if defined?(RSpec) and RSpec.respond_to?(:configure)
require 'draper/test/minitest_integration' if defined?(MiniTest::Rails)
