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
      decorate_collection(finder_class.all, options)
    end

    def first(options = {})
      decorate(finder_class.first, options)
    end

    def last(options = {})
      decorate(finder_class.last, options)
    end

    def method_missing(method, *args, &block)
      result = finder_class.send(method, *args, &block)
      options = args.extract_options!

      case method.to_s
      when /^find_((last_)?by_|or_(initialize|create)_by_)/
        decorate(result, options)
      when /^find_all_by_/
        decorate_collection(result, options)
      else
        result
      end
    end

    def respond_to?(method, include_private = false)
      super || finder_class.respond_to?(method)
    end

  end
end
