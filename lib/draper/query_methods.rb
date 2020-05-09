require_relative 'query_methods/load_strategy'

module Draper
  module QueryMethods
    # Proxies missing query methods to the source class if the strategy allows.
    ruby2_keywords def method_missing(method, *args, &block)
      return super unless strategy.allowed? method

      object.send(method, *args, &block).decorate(with: decorator_class, context: context)
    end

    def respond_to_missing?(method, include_private = false)
      strategy.allowed?(method) || super
    end

    private

    # Configures the strategy used to proxy the query methods, which defaults to `:active_record`.
    def strategy
      @strategy ||= LoadStrategy.new(Draper.default_query_methods_strategy)
    end
  end
end
