require 'action_view'

require 'draper/version'
require 'draper/system'
require 'draper/active_model_support'
require 'draper/base'
require 'draper/lazy_helpers'
require 'draper/model_support'
require 'draper/helper_support'
require 'draper/view_context'
require 'draper/decorated_enumerable_proxy'
require 'draper/rspec_integration' if defined?(RSpec) and RSpec.respond_to?(:configure)
require 'draper/minitest_integration' if defined?(MiniTest)
require 'draper/railtie' if defined?(Rails)

