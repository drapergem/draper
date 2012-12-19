module Draper
  class CollectionDecorator
    include Enumerable
    include ViewHelpers

    attr_reader :source
    alias_method :to_source, :source

    attr_accessor :context

    array_methods = Array.instance_methods - Object.instance_methods
    delegate :as_json, *array_methods, to: :decorated_collection

    # @param source collection to decorate
    # @option options [Class] :with the class used to decorate items
    # @option options [Hash] :context context available to each item's decorator
    def initialize(source, options = {})
      options.assert_valid_keys(:with, :context)
      @source = source
      @decorator_class = options[:with]
      @context = options.fetch(:context, {})
    end

    class << self
      alias_method :decorate, :new
    end

    def decorated_collection
      @decorated_collection ||= source.collect {|item| decorate_item(item) }
    end

    def find(*args, &block)
      if block_given?
        decorated_collection.find(*args, &block)
      else
        decorator_class.find(*args)
      end
    end

    def method_missing(method, *args, &block)
      source.send(method, *args, &block)
    end

    def respond_to?(method, include_private = false)
      super || source.respond_to?(method, include_private)
    end

    def kind_of?(klass)
      super || source.kind_of?(klass)
    end
    alias_method :is_a?, :kind_of?

    def ==(other)
      source == (other.respond_to?(:source) ? other.source : other)
    end

    def to_s
      "#<CollectionDecorator of #{decorator_class} for #{source.inspect}>"
    end

    def context=(value)
      @context = value
      each {|item| item.context = value } if @decorated_collection
    end

    def decorator_class
      @decorator_class ||= self.class.inferred_decorator_class
    end

    protected

    def decorate_item(item)
      item_decorator.call(item, context: context)
    end

    def self.inferred_decorator_class
      decorator_name = "#{name.chomp("Decorator").singularize}Decorator"
      decorator_uninferrable if decorator_name == name

      decorator_name.constantize

    rescue NameError
      decorator_uninferrable
    end

    def self.decorator_uninferrable
      raise Draper::UninferrableDecoratorError.new(self)
    end

    private

    def item_decorator
      @item_decorator ||= begin
        decorator_class.method(:decorate)
      rescue Draper::UninferrableDecoratorError
        ->(item, options) { item.decorate(options) }
      end
    end
  end
end
