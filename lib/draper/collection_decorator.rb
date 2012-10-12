require 'active_support/core_ext/object/blank'
module Draper
  class CollectionDecorator
    include Enumerable

    delegate :as_json, :collect, :map, :each, :[], :all?, :include?, :first, :last, :shift, :in_groups_of, :to => :decorated_collection

    # Initialize a new collection decorator instance by passing in
    # an instance of a collection. Pass in an optional
    # context into the options hash is stored for later use.
    #
    #
    # @param [Object] instances to wrap
    # @param [Hash] options (optional)
    # @option options [Class] :class The decorator class to use
    #   for each item in the collection.
    # @option options all other options are passed to Decorator
    #   class for each item.

    def self.decorate(collection, options = {})
      new( collection, discern_class_from_my_class(options.delete(:class)), options)
    end
    class << self
      alias_method :decorates, :decorate
    end

    def initialize(collection, klass, options = {})
      @wrapped_collection, @klass, @options = collection, klass, options
    end

    def decorated_collection
      @decorated_collection ||= @wrapped_collection.collect { |member| @klass.decorate(member, @options) }
    end
    alias_method :to_ary, :decorated_collection

    def find(ifnone_or_id = nil, &blk)
      if block_given?
        decorated_collection.find(ifnone_or_id, &blk)
      else
        obj = decorated_collection.first
        return nil if obj.blank?
        obj.class.find(ifnone_or_id)
      end
    end

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
      @wrapped_collection == (other.respond_to?(:source) ? other.source : other)
    end

    def to_s
      "#<CollectionDecorator of #{@klass} for #{@wrapped_collection.inspect}>"
    end

    def context=(input)
      self.map { |member| member.context = input }
    end

    def source
      @wrapped_collection
    end
    alias_method :to_source, :source

    def helpers
      Draper::ViewContext.current
    end
    alias_method :h, :helpers

    private
    def self.discern_class_from_my_class default_class
      return default_class if default_class
      name = self.to_s.gsub("Decorator", "")
      "#{name.singularize}Decorator".constantize
    rescue NameError
      raise NameError("You must supply a class (as the klass option) for the members of your collection or the class must be inferable from the name of this class ('#{new.class}')")
    end
  end
end
