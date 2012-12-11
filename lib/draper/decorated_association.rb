module Draper
  class DecoratedAssociation

    attr_reader :source, :association, :options

    def initialize(source, association, options)
      @source = source
      @association = association
      @options = options
    end

    def call
      return undecorated if undecorated.nil?
      decorate
    end

    private

    def undecorated
      @undecorated ||= begin
        associated = source.send(association)
        associated = associated.send(options[:scope]) if options[:scope]
        associated
      end
    end

    def decorate
      @decorated ||= decorator_class.send(decorate_method, undecorated, options)
    end

    def decorate_method
      if collection? && decorator_class.respond_to?(:decorate_collection)
        :decorate_collection
      else
        :decorate
      end
    end

    def collection?
      undecorated.respond_to?(:first)
    end

    def decorator_class
      return options[:with] if options[:with]

      if collection?
        options[:with] = :infer
        Draper::CollectionDecorator
      else
        undecorated.decorator_class
      end
    end

  end
end
