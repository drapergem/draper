module Draper
  class Factory
    # Creates a decorator factory.
    #
    # @option options [Decorator, CollectionDecorator] :with (nil)
    #   decorator class to use. If nil, it is inferred from the object
    #   passed to {#decorate}.
    # @option options [Hash, #call] context
    #   extra data to be stored in created decorators. If a proc is given, it
    #   will be called each time {#decorate} is called and its return value
    #   will be used as the context.
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
    # @option options [Object, Array] context_args (nil)
    #   argument(s) to be passed to the context proc.
    # @return [Decorator, CollectionDecorator] the decorated object.
    def decorate(source, options = {})
      return nil if source.nil?
      Worker.new(decorator_class, source).call(options.reverse_merge(default_options))
    end

    private

    attr_reader :decorator_class, :default_options

    # @private
    class Worker
      def initialize(decorator_class, source)
        @decorator_class = decorator_class
        @source = source
      end

      def call(options)
        update_context options
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

      def update_context(options)
        args = options.delete(:context_args)
        options[:context] = options[:context].call(*Array.wrap(args)) if options[:context].respond_to?(:call)
      end
    end
  end
end
