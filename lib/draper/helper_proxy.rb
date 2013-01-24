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
      view_context.send(method, *args, &block)
    end

    protected

    attr_reader :view_context

    private

    def current_view_context
      ActiveSupport::Deprecation.warn("wrong number of arguments (0 for 1) passed to Draper::HelperProxy.new", caller[1..-1])
      Draper::ViewContext.current.view_context
    end
  end
end
