module Draper
  module LazyHelpers
    def method_missing(method_name, *args, &block)
      begin
        helpers.send method_name, *args, &block
      rescue NoMethodError
        super
      end
    end
  end
end
