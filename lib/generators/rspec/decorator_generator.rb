module Rspec
  module Generators
    class DecoratorGenerator < ::Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)

      def create_spec_file
        template 'decorator_spec.rb', File.join('spec/decorators', class_path, "#{singular_name}_decorator_spec.rb")
      end
    end
  end
end
