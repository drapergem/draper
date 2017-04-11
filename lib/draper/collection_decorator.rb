module Draper
  class CollectionDecorator
    include Enumerable
    include Draper::ViewHelpers
    extend Draper::Delegation

    # @return the collection being decorated.
    attr_reader :object

    # @return [Class] the decorator class used to decorate each item, as set by
    #   {#initialize}.
    attr_reader :decorator_class

    # @return [Hash] extra data to be used in user-defined methods, and passed
    #   to each item's decorator.
    attr_accessor :context

    array_methods = Array.instance_methods - Object.instance_methods
    delegate :==, :as_json, :all, :last!, *array_methods, to: :decorated_collection

    # @param [Enumerable] object
    #   collection to decorate.
    # @option options [Class, nil] :with (nil)
    #   the decorator class used to decorate each item. When `nil`, each item's
    #   {Decoratable#decorate decorate} method will be used.
    # @option options [Hash] :context ({})
    #   extra data to be stored in the collection decorator and used in
    #   user-defined methods, and passed to each item's decorator.
    def initialize(object, options = {})
      options.assert_valid_keys(:with, :context)
      @object = object
      @decorator_class = options[:with]
      @context = options.fetch(:context, {})
    end

    class << self
      alias_method :decorate, :new
    end

    # @return [Array] the decorated items.
    def decorated_collection
      return @decorated_collection if instance_variable_defined?(:'@decorated_collection')
      if defined?(ActiveRecord) && object.kind_of?(ActiveRecord::Relation)
        @decorated_collection ||= RelationProxy.new(object) { |item| decorate_item(item) }
      else
        @decorated_collection ||= object.map{|item| decorate_item(item)}
      end
    end

    delegate :find, to: :decorated_collection

    def to_s
      "#<#{self.class.name} of #{decorator_class || "inferred decorators"} for #{object.inspect}>"
    end

    def context=(value)
      @context = value
      each {|item| item.context = value } if @decorated_collection
    end

    # @return [true]
    def decorated?
      true
    end

    alias_method :decorated_with?, :instance_of?

    def kind_of?(klass)
      decorated_collection.kind_of?(klass) || super
    end
    alias_method :is_a?, :kind_of?

    def replace(other)
      decorated_collection.replace(other)
      self
    end

    def method_missing(method, *args, &block)
      if object.respond_to?(method)
        self.class.send :define_method, method do |*args, &block|
          scoped_result = object.send(method, *args, &block)
          if defined?(ActiveRecord) && scoped_result.kind_of?(ActiveRecord::Relation)
            self.class.new(scoped_result, context: context)
          else
            scoped_result
          end
        end

        send method, *args, &block
      else
        super
      end

    rescue NoMethodError => no_method_error
      super if no_method_error.name == method
      raise no_method_error
    end

    protected

    # Decorates the given item.
    def decorate_item(item)
      item_decorator.call(item, context: context)
    end

    private

    def item_decorator
      if decorator_class
        decorator_class.method(:decorate)
      else
        ->(item, options) { item.decorate(options) }
      end
    end

    public

    class RelationProxy < SimpleDelegator
      def initialize(object, &block)
        super(object)
        @block = block
      end

      def method_missing(method, *args, &block)
        result = __getobj__.send(method, *args, &block)
        if result.is_a?(Array)
          result.map{|item| @block.call(item) }
        elsif __getobj__.respond_to?(:klass) && result.is_a?(__getobj__.klass)
          @block.call(result)
        else
          result
        end
      end
    end
  end
end
