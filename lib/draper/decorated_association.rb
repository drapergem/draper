require 'draper/collection_decorator'

module Draper
  # @private
  class DecoratedAssociation

    VALID_OPTIONS = [:scope] + CollectionDecorator::VALID_OPTIONS

    def initialize(owner, association, options)
      options.assert_valid_keys(*DecoratedAssociation::VALID_OPTIONS)

      @owner       = owner
      @association = association
      @scope       = options[:scope]

      factory_options = options.slice(*CollectionDecorator::VALID_OPTIONS)
      factory_options[:context] ||= ->(context){ context }

      @factory = Draper::Factory.new(factory_options)
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
