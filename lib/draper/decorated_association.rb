module Draper
  # @private
  class DecoratedAssociation

    def initialize(owner, association, options)
      options.assert_valid_keys(:with, :namespace, :scope, :context)

      @owner = owner
      @association = association

      @scope = options[:scope]

      decorator_class = options[:with]
      namespace = options[:namespace]
      context = options.fetch(:context, ->(context){ context })

      @factory = Draper::Factory.new(with: decorator_class, namespace: namespace, context: context)
    end

    def call
      decorate unless defined?(@decorated)
      @decorated
    end

    private

    attr_reader :factory, :owner, :association, :scope

    def decorate
      associated = owner.source.send(association)
      associated = associated.send(scope) if scope

      @decorated = factory.decorate(associated, context_args: owner.context)
    end

  end
end
