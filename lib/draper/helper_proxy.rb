module Draper
  # Provides access to helper methods - both Rails built-in helpers, and those
  # defined in your application.
  class HelperProxy

    # @overload initialize(view_context)
    def initialize(view_context = nil)
      view_context ||= current_view_context # backwards compatibility

      @view_context = view_context
    end

    # Sends helper methods to the view context.
    def method_missing(method, *args, &block)
      self.class.define_proxy method
      send(method, *args, &block)
    end

    # Checks if the context responds to an instance method, or is able to
    # proxy it to the view context.
    def respond_to_missing?(method, include_private = false)
      super || view_context.respond_to?(method)
    end

    delegate :capture, to: :view_context

    protected

    attr_reader :view_context

    private

    def self.define_proxy(name)
      define_method name do |*args, &block|
        view_context.send(name, *args, &block)
      end
    end

    def current_view_context
      ActiveSupport::Deprecation.warn("wrong number of arguments (0 for 1) passed to Draper::HelperProxy.new", caller[1..-1])
      Draper::ViewContext.current.view_context
    end
  end
end
