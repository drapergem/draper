module Draper
  class DecoratedAssociation

    attr_reader :base, :association, :options

    def initialize(base, association, options)
      @base = base
      @association = association
      options.assert_valid_keys(:with, :scope, :context)
      @options = options
    end

    def call
      return undecorated if undecorated.nil?
      decorate
    end

    def source
      base.source
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
      @decorated ||= decorator_class.send(decorate_method, undecorated, decorator_options)
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
      return Draper::CollectionDecorator if options[:with] == :infer
      return options[:with] if options[:with]

      if collection?
        options[:with] = :infer
        decorator_class
      else
        undecorated.decorator_class
      end
    end

    def decorator_options
      decorator_class # Ensures options[:with] = :infer for unspecified collections

      dec_options = collection? ? options.slice(:with, :context) : options.slice(:context)
      dec_options[:context] = base.context unless dec_options.key?(:context)
      if dec_options[:context].respond_to?(:call)
        dec_options[:context] = dec_options[:context].call(base.context) 
      end
      dec_options
    end
  end
end
