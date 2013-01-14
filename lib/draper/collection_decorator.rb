module Draper
  class CollectionDecorator
    include Enumerable
    include Draper::ViewHelpers
    extend Draper::Delegation

    # @return [Hash] extra data to be used in user-defined methods, and passed
    #   to each item's decorator.
    attr_accessor :context

    array_methods = Array.instance_methods - Object.instance_methods
    delegate :==, :as_json, *array_methods, to: :decorated_collection

    # @param [Enumerable] source
    #   collection to decorate.
    # @option options [Class, nil] :with (nil)
    #   the decorator class used to decorate each item. When `nil`, it is
    #   inferred from the collection decorator class if possible (e.g.
    #   `ProductsDecorator` maps to `ProductDecorator`), otherwise each item's
    #   {Decoratable#decorate decorate} method will be used.
    # @option options [Hash] :context ({})
    #   extra data to be stored in the collection decorator and used in
    #   user-defined methods, and passed to each item's decorator.
    def initialize(source, options = {})
      options.assert_valid_keys(:with, :context)
      @source = source
      @decorator_class = options[:with]
      @context = options.fetch(:context, {})
    end

    class << self
      alias_method :decorate, :new
    end

    # @return [Array] the decorated items.
    def decorated_collection
      @decorated_collection ||= source.map{|item| decorate_item(item)}
    end

    # Delegated to the decorated collection when using the block form
    # (`Enumerable#find`) or to the decorator class if not
    # (`ActiveRecord::FinderMethods#find`)
    def find(*args, &block)
      if block_given?
        decorated_collection.find(*args, &block)
      else
        decorator_class.find(*args)
      end
    end

    def to_s
      klass = begin
        decorator_class
      rescue Draper::UninferrableDecoratorError
        "inferred decorators"
      end

      "#<#{self.class.name} of #{klass} for #{source.inspect}>"
    end

    def context=(value)
      @context = value
      each {|item| item.context = value } if @decorated_collection
    end

    # @return [Class] the decorator class used to decorate each item, as set by
    #   {#initialize} or as inferred from the collection decorator class (e.g.
    #   `ProductsDecorator` maps to `ProductDecorator`).
    def decorator_class
      @decorator_class ||= self.class.inferred_decorator_class
    end

    protected

    # @return the collection being decorated.
    attr_reader :source

    # Decorates the given item.
    def decorate_item(item)
      item_decorator.call(item, context: context)
    end

    private

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

    def item_decorator
      @item_decorator ||= begin
        decorator_class.method(:decorate)
      rescue Draper::UninferrableDecoratorError
        ->(item, options) { item.decorate(options) }
      end
    end
  end
end
