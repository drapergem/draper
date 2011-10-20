module Draper
  class DecoratedEnumerableProxy
    include Enumerable

    def initialize(collection, klass, context)
      @wrapped_collection, @klass, @context = collection, klass, context
    end

    # Implementation of Enumerable#each that proxyes to the wrapped collection
    def each(&block)
      @wrapped_collection.each { |member| block.call(@klass.new(member, @context)) }
    end

    # Implement to_arry so that render @decorated_collection is happy
    def to_ary
      @wrapped_collection.to_ary
    end

    def method_missing (meth, *args, &block)
      @wrapped_collection.send(meth, *args, &block)
    end

    def respond_to?(meth)
      super || @wrapped_collection.respond_to?(meth)
    end

    def to_s
      "#<DecoratedEnumerableProxy of #{@klass} for #{@wrapped_collection.inspect}>"
    end
  end
end
