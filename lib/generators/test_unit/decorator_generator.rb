module TestUnit
  class DecoratorGenerator < ::Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)

    TEST_ROOT = 'test/decorators/'
    APPLICATION_DECORATOR_TEST = 'application_decorator_test.rb'
    APPLICATION_DECORATOR_TEST_PATH = TEST_ROOT + APPLICATION_DECORATOR_TEST

    def build_model_and_application_decorator_tests
      empty_directory TEST_ROOT
      unless File.exists?(APPLICATION_DECORATOR_TEST_PATH)
        template APPLICATION_DECORATOR_TEST, APPLICATION_DECORATOR_TEST_PATH
      end
      template 'decorator_test.rb', "#{TEST_ROOT}#{singular_name}_decorator_test.rb"
    end
  end
end
