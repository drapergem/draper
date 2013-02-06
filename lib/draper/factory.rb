module Draper
  class Factory
    # Creates a decorator factory.
    #
    # @option options [Decorator,CollectionDecorator] :with (nil)
    #   decorator class to use. If nil, it is inferred from the object
    #   passed to {#decorate}.
    # @option options [Hash] context
    #   extra data to be stored in created decorators.
    def initialize(options = {})
      options.assert_valid_keys(:with, :context)
      @decorator_class = options.delete(:with)
      @default_options = options
    end

    # Decorates an object, inferring whether to create a singular or collection
    # decorator from the type of object passed.
    #
    # @param [Object] source
    #   object to decorate.
    # @option options [Hash] context
    #   extra data to be stored in the decorator. Overrides any context passed
    #   to the constructor.
    # @return [Decorator, CollectionDecorator] the decorated object.
    def decorate(source, options = {})
      return nil if source.nil?
      Worker.new(decorator_class, source).call(options.reverse_merge(default_options))
    end

    private

    attr_reader :decorator_class, :default_options

    class Worker
      def initialize(decorator_class, source)
        @decorator_class = decorator_class
        @source = source
      end

      def call(options)
        decorator.call(source, options)
      end

      def decorator
        return collection_decorator if collection?
        decorator_class.method(:decorate)
      end

      private

      attr_reader :source

      def collection_decorator
        klass = decorator_class || Draper::CollectionDecorator

        if klass.respond_to?(:decorate_collection)
          klass.method(:decorate_collection)
        else
          klass.method(:decorate)
        end
      end

      def collection?
        source.respond_to?(:first)
      end

      def decorator_class
        @decorator_class || source_decorator_class
      end

      def source_decorator_class
        source.decorator_class if source.respond_to?(:decorator_class)
      end
    end
  end
end
