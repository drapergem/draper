module Draper
  # Include this module in your decorators to get direct access to the helpers
  # so that you can stop typing `h.` everywhere, at the cost of mixing in a
  # bazillion methods.
  module LazyHelpers

    # Sends missing methods to the {HelperProxy}.
    def method_missing(method, *args, &block)
      helpers.send(method, *args, &block)
    rescue NoMethodError
      super
    end

  end
end
