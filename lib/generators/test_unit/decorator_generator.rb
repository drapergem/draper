module TestUnit
  class DecoratorGenerator < ::Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)

    TEST_ROOT = 'test/decorators/'

    def build_model_decorator_tests
      template 'decorator_test.rb', "#{TEST_ROOT}#{singular_name}_decorator_test.rb"
    end
  end
end
