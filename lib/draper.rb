require 'action_view'
require 'active_model/naming'
require 'active_model/serialization'
require 'active_model/serializers/json'
require 'active_model/serializers/xml'
require 'active_support/inflector'
require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/hash/reverse_merge'
require 'active_support/core_ext/name_error'

require 'ruby2_keywords'

require 'draper/version'
require 'draper/configuration'
require 'draper/view_helpers'
require 'draper/compatibility/api_only'
require 'draper/delegation'
require 'draper/automatic_delegation'
require 'draper/finders'
require 'draper/decorator'
require 'draper/helper_proxy'
require 'draper/lazy_helpers'
require 'draper/decoratable'
require 'draper/factory'
require 'draper/decorated_association'
require 'draper/helper_support'
require 'draper/view_context'
require 'draper/query_methods'
require 'draper/collection_decorator'
require 'draper/undecorate'
require 'draper/decorates_assigned'
require 'draper/railtie' if defined?(Rails)

module Draper
  extend Draper::Configuration

  def self.setup_action_controller(base)
    base.class_eval do
      include Draper::Compatibility::ApiOnly if base == ActionController::API
      include Draper::ViewContext
      extend  Draper::HelperSupport
      extend  Draper::DecoratesAssigned

      before_action :activate_draper
    end
  end

  def self.setup_action_mailer(base)
    base.class_eval do
      include Draper::ViewContext
    end
  end

  def self.setup_orm(base)
    base.class_eval do
      include Draper::Decoratable
    end
  end

  class UninferrableDecoratorError < NameError
    def initialize(klass)
      super("Could not infer a decorator for #{klass}.")
    end
  end

  class UninferrableObjectError < NameError
    def initialize(klass)
      super("Could not infer an object for #{klass}.")
    end
  end
end
