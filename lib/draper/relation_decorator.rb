module Draper
  class RelationDecorator
    include Draper::ViewHelpers
    extend Draper::Delegation

    # @return [Class] the decorator class used to decorate this relation, as set by
    #   {#initialize}.
    attr_reader :decorator_class

    # @return [Hash] extra data to be used in user-defined methods, and passed
    #   to each item's decorator.
    attr_accessor :context

    # @param [ActiveRecord::Relation] relation
    #   relation to decorate.
    # @option options [Class, nil] :with (nil)
    #   the decorator class used to decorate each item. When `nil`, each item's
    #   {Decoratable#decorate decorate} method will be used.
    # @option options [Hash] :context ({})
    #   extra data to be stored in the relation decorator and used in
    #   user-defined methods, and passed to each item's decorator.
    def initialize(relation, options = {})
      options.assert_valid_keys(:with, :context)
      @relation = relation
      @decorator_class = options[:with]
      @decorator_class ||= klass.decorator_class if relation.respond_to?(:klass) && klass.respond_to?(:decorator_class)
      @context = options.fetch(:context, {})
    end

    class << self
      alias_method :decorate, :new
    end

    def to_s
      "#<#{self.class.name} of #{decorator_class || "inferred decorators"} for #{relation.inspect}>"
    end

    def context=(value)
      @context = value
    end

    # @return [true]
    def decorated?
      true
    end

    alias_method :decorated_with?, :instance_of?

    def decorating_class
      return decorator_class if decorator_class
      self.class
    end

    def method_missing(method, *args, &block)
      block ?
        relation.send(method, *args, &proxy_block(&block)) :
        handle_result(relation.send(method, *args))
    end

    def proxy_block(&original_block)
      -> (data) { original_block.call(handle_result(data)) }
    end

    def handle_result(result)
      if defined?(ActiveRecord) && result.is_a?(ActiveRecord::Relation)
        return self.class.decorate(result, context: context)
      elsif result.is_a?(Array)
        return Decorator.collection_decorator_class.new(result, context: context)
      elsif relation.respond_to?(:klass) && result.is_a?(relation.klass) && klass.respond_to?(:decorate)
        return result.decorate(context: context)
      else
        return result
      end
    end

    protected

    # @return the relation being decorated.
    attr_reader :relation

  end
end