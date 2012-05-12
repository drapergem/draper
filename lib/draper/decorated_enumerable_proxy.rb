module Draper
  class DecoratedEnumerableProxy
    include Enumerable

    delegate :as_json, :collect, :map, :each, :[], :all?, :include?, :first, :last, :shift, :to => :decorated_collection

    def initialize(collection, klass, options = {})
      @wrapped_collection, @klass, @options = collection, klass, options
    end

    def decorated_collection
      @decorated_collection ||= @wrapped_collection.collect { |member| @klass.decorate(member, @options) }
    end
    alias_method :to_ary, :decorated_collection

    def method_missing (method, *args, &block)
      @wrapped_collection.send(method, *args, &block)
    end

    def respond_to?(method, include_private = false)
      super || @wrapped_collection.respond_to?(method, include_private)
    end

    def kind_of?(klass)
      @wrapped_collection.kind_of?(klass) || super
    end
    alias :is_a? :kind_of?

    def ==(other)
      @wrapped_collection == other
    end

    def to_s
      "#<DecoratedEnumerableProxy of #{@klass} for #{@wrapped_collection.inspect}>"
    end

    def context=(input)
      self.map { |member| member.context = input }
    end

    def source
      @wrapped_collection
    end
    alias_method :to_source, :source
  end
end
