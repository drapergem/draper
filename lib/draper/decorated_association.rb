module Draper
  # @private
  class DecoratedAssociation

    def initialize(owner, association, options)
      options.assert_valid_keys(:with, :scope, :context)

      @owner = owner
      @association = association

      @scope = options[:scope]
      @context = options.fetch(:context, ->(context){ context })

      @factory = Draper::Factory.new(options.slice(:with))
    end

    def call
      decorate unless defined?(@decorated)
      @decorated
    end

    def context
      return @context.call(owner.context) if @context.respond_to?(:call)
      @context
    end

    private

    attr_reader :factory, :owner, :association, :scope

    def decorate
      associated = owner.source.send(association)
      associated = associated.send(scope) if scope

      @decorated = factory.decorate(associated, context: context)
    end

  end
end
