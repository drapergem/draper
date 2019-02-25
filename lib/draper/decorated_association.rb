module Draper
  # @private
  class DecoratedAssociation
    def initialize(owner, association, options)
      options.assert_valid_keys(:with, :scope, :context)

      @owner = owner
      @association = association

      @scope = options[:scope]

      decorator_class = options[:with]
      context = options.fetch(:context, ->(context){ context })
      @factory = Draper::Factory.new(with: decorator_class, context: context)
    end

    def call
      decorate unless defined?(@decorated)
      @decorated
    end

    private

    attr_reader :factory, :owner, :association, :scope

    def decorate
      associated = owner.object.send(association)
      associated = associated.send(scope) if scope

      @decorated = factory.decorate(associated, context_args: owner.context)
    end
  end
end
