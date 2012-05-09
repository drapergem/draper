require "rails/generators"
require "rails/generators/rails/resource/resource_generator"

module Rails
  module Generators
    ResourceGenerator.class_eval do
      def add_decorator
        invoke "decorator"
      end
    end
  end
end
