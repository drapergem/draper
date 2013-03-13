module Draper
  class CollectionDecorator
    include Enumerable
    include Draper::ViewHelpers
    extend Draper::Delegation

    VALID_OPTIONS = [:with] + Decorator::VALID_OPTIONS

    # @return [Class] the decorator class used to decorate each item, as set by
    #   {#initialize}.
    def decorator_class
      @decoration_options[:with]
    end

    # @return [Hash] extra data to be used in user-defined methods, and passed
    #   to each item's decorator.
    def context
      @decoration_options[:context]
    end

    def context=(value)
      @decoration_options[:context] = value
      each {|item| item.context = value } if @decorated_collection
    end

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
      options.assert_valid_keys(*CollectionDecorator::VALID_OPTIONS)
      @source             = source
      @decoration_options = options.reverse_merge(context: {})
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
      "#<#{self.class.name} of #{decorator_class || "inferred decorators"} for #{source.inspect}>"
    end

    # @return [true]
    def decorated?
      true
    end

    def kind_of?(klass)
      decorated_collection.kind_of?(klass) || super
    end
    alias_method :is_a?, :kind_of?

    protected

    # @return the collection being decorated.
    attr_reader :source

    # Decorates the given item.
    def decorate_item(item)
      if decorator_class
        decorator_class.decorate(item, @decoration_options.slice(*Decorator::VALID_OPTIONS))
      else
        item.decorate(@decoration_options.slice(*Decorator::VALID_OPTIONS))
      end
    end

  end
end
