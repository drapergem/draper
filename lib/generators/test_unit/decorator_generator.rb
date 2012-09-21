module TestUnit
  class DecoratorGenerator < ::Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)

    def create_test_file
      template 'decorator_test.rb', File.join('test/decorators', class_path, "#{singular_name}_decorator_test.rb")
    end
  end
end
