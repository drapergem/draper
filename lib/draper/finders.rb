module Draper
  # Provides automatically-decorated finder methods for your decorators. You
  # do not have to extend this module directly; it is extended by
  # {Decorator.decorates_finders}.
  module Finders

    def find(id, options = {})
      decorate(source_class.find(id), options)
    end

    def all(options = {})
      decorate_collection(source_class.all, options)
    end

    def first(options = {})
      decorate(source_class.first, options)
    end

    def last(options = {})
      decorate(source_class.last, options)
    end

    # Decorates dynamic finder methods (`find_all_by_` and friends).
    def method_missing(method, *args, &block)
      return super unless method =~ /^find_(all_|last_|or_(initialize_|create_))?by_/

      result = source_class.send(method, *args, &block)
      options = args.extract_options!

      if method =~ /^find_all/
        decorate_collection(result, options)
      else
        decorate(result, options)
      end
    end
  end
end
