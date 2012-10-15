module Draper
  class HelperProxy
    # Some helpers are private, for example html_escape... as a workaround
    # we are wrapping the helpers in a delegator that passes the methods
    # along through a send, which will ignore private/public distinctions
    def method_missing(method, *args, &block)
      view_context.send(method, *args, &block)
    end

    private

    def view_context
      Draper::ViewContext.current
    end
  end
end
