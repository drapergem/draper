module Draper
  class CollectionDecorator
    include Enumerable
    include Draper::ViewHelpers
    include Draper::QueryMethods
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
    delegate :==, :as_json, *array_methods, to: :decorated_collection

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
      alias :decorate :new
    end

    # @return [Array] the decorated items.
    def decorated_collection
      @decorated_collection ||= object.map{|item| decorate_item(item)}
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

    alias :decorated_with? :instance_of?

    def kind_of?(klass)
      decorated_collection.kind_of?(klass) || super
    end

    alias_method :is_a?, :kind_of?

    def replace(other)
      decorated_collection.replace(other)
      self
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
  end
end
