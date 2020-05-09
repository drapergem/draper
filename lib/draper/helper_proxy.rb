module Draper
  # Provides access to helper methods - both Rails built-in helpers, and those
  # defined in your application.
  class HelperProxy
    # @overload initialize(view_context)
    def initialize(view_context)
      @view_context = view_context
    end

    # Sends helper methods to the view context.
    ruby2_keywords def method_missing(method, *args, &block)
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
      ruby2_keywords name
    end
  end
end
