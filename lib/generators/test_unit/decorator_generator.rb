module TestUnit
  module Generators
    class DecoratorGenerator < ::Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)
      check_class_collision suffix: "DecoratorTest"

      def create_test_file
        template 'decorator_test.rb', File.join('test/decorators', class_path, "#{singular_name}_decorator_test.rb")
      end
    end
  end
end
