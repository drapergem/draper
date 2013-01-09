module Draper
  # @private
  class DecoratedAssociation

    def initialize(owner, association, options)
      options.assert_valid_keys(:with, :scope, :context)

      @owner = owner
      @association = association

      @decorator_class = options[:with]
      @scope = options[:scope]
      @context = options.fetch(:context, owner.context)
    end

    def call
      return undecorated if undecorated.nil?
      decorated
    end

    def context
      return @context.call(owner.context) if @context.respond_to?(:call)
      @context
    end

    private

    attr_reader :owner, :association, :scope

    def source
      owner.source
    end

    def undecorated
      @undecorated ||= begin
        associated = source.send(association)
        associated = associated.send(scope) if scope
        associated
      end
    end

    def decorated
      @decorated ||= decorator.call(undecorated, context: context)
    end

    def collection?
      undecorated.respond_to?(:first)
    end

    def decorator
      return collection_decorator if collection?
      decorator_class.method(:decorate)
    end

    def collection_decorator
      klass = decorator_class || Draper::CollectionDecorator

      if klass.respond_to?(:decorate_collection)
        klass.method(:decorate_collection)
      else
        klass.method(:decorate)
      end
    end

    def decorator_class
      @decorator_class || inferred_decorator_class
    end

    def inferred_decorator_class
      undecorated.decorator_class if undecorated.respond_to?(:decorator_class)
    end

  end
end
