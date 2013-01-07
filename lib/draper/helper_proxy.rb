module Draper
  # Provides access to helper methods - both Rails built-in helpers, and those
  # defined in your application.
  class HelperProxy

    # Sends helper methods to the view context.
    def method_missing(method, *args, &block)
      view_context.send(method, *args, &block)
    end

    private

    def view_context
      Draper::ViewContext.current
    end
  end
end
