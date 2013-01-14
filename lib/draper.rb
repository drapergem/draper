require 'action_view'

require 'draper/version'
require 'draper/view_helpers'
require 'draper/delegation'
require 'draper/automatic_delegation'
require 'draper/finders'
require 'draper/decorator'
require 'draper/helper_proxy'
require 'draper/lazy_helpers'
require 'draper/decoratable'
require 'draper/decorated_association'
require 'draper/helper_support'
require 'draper/view_context'
require 'draper/collection_decorator'
require 'draper/railtie' if defined?(Rails)

require 'active_support/core_ext/hash/keys'

module Draper
  def self.setup_action_controller(base)
    base.class_eval do
      include Draper::ViewContext
      extend  Draper::HelperSupport
      before_filter ->(controller) {
        Draper::ViewContext.current = nil
        Draper::ViewContext.current_controller = controller
      }
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

  class UninferrableSourceError < NameError
    def initialize(klass)
      super("Could not infer a source for #{klass}.")
    end
  end
end
