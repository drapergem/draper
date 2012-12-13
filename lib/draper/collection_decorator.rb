require 'draper'

module Draper
  class CollectionDecorator
    include Enumerable
    include ViewHelpers

    attr_accessor :source, :options, :decorator_class
    protected :options, :options=
    alias_method :to_source, :source

    delegate :as_json, *(Array.instance_methods - Object.instance_methods), to: :decorated_collection

    # @param source collection to decorate
    # @param [Hash] options (optional)
    # @option options [Class, Symbol] :with the class used to decorate
    #   items, or `:infer` to call each item's `decorate` method instead
    # @option options [Hash] :context context available to each item's decorator
    def initialize(source, options = {})
      @source = source
      @decorator_class = options.delete(:with) || self.class.inferred_decorator_class
      Draper.validate_options(options, :with, :context)
      @options = options
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

    # Accessor for `:context` option
    def context
      options.fetch(:context, {})
    end

    # Setter for `:context` option
    def context=(input)
      options[:context] = input
      each {|item| item.context = input } unless respond_to?(:loaded?) && !loaded?
    end

    protected

    def decorate_item(item)
      if decorator_class == :infer
        item.decorate(context: context)
      else
        decorator_class.decorate(item, context: context)
      end
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
  end
end
