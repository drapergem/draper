module Draper
  class DecoratedEnumerableProxy
    include Enumerable

    def initialize(collection, klass, context)
      @wrapped_collection, @klass, @context = collection, klass, context
    end

    # Implementation of Enumerable#each that proxies to the wrapped collection
    def each(&block)
      @wrapped_collection.each { |member| block.call(@klass.new(member, @context)) }
    end

    # Implement to_arry so that render @decorated_collection is happy
    def to_ary
      @wrapped_collection.to_ary
    end

    def method_missing (method, *args, &block)
      @wrapped_collection.send(method, *args, &block)
    end

    def respond_to?(method)
      super || @wrapped_collection.respond_to?(method)
    end

    def to_s
      "#<DecoratedEnumerableProxy of #{@klass} for #{@wrapped_collection.inspect}>"
    end
  end
end
