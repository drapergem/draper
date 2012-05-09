module Draper
  class DecoratedEnumerableProxy
    include Enumerable

    def initialize(collection, klass, options = {})
      @wrapped_collection, @klass, @options = collection, klass, options
    end

    def each(&block)
      @wrapped_collection.each { |member| block.call(@klass.decorate(member, @options)) }
    end

    def to_ary
      @wrapped_collection.map { |member| @klass.decorate(member, @options) }
    end

    def method_missing (method, *args, &block)
      # this is absolutely gross, but for now, it works.
      # There should be a better solution, for sure.
      if method == :last && @wrapped_collection.respond_to?(:last)
        @klass.decorate(@wrapped_collection.last)
      elsif method == :shift && @wrapped_collection.respond_to?(:shift)
        @klass.decorate(@wrapped_collection.shift)
      else
        @wrapped_collection.send(method, *args, &block)
      end
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

    def [](index)
      @klass.new(@wrapped_collection[index], @options)
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
