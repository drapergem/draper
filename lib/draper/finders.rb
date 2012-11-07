module Draper
  module Finders

    attr_reader :finder_class
    def finder_class=(klass)
      @finder_class = klass.to_s.camelize.constantize
    end

    def find(id, options = {})
      decorate(finder_class.find(id), options)
    end

    def all(options = {})
      decorate(finder_class.all, options)
    end

    def first(options = {})
      decorate(finder_class.first, options)
    end

    def last(options = {})
      decorate(finder_class.last, options)
    end

    def method_missing(method, *args, &block)
      if method.to_s.match(/^find_((all_|last_)?by_|or_(initialize|create)_by_).*/)
        decorate(finder_class.send(method, *args, &block), args.dup.extract_options!)
      else
        finder_class.send(method, *args, &block)
      end
    end

    def respond_to?(method, include_private = false)
      super || finder_class.respond_to?(method)
    end

  end
end
