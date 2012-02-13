module Draper
  class DecoratorGenerator < Rails::Generators::Base
    desc <<-DESC
    Description:
        Generate a decorator for the given model.
        Example: rails g draper:decorator Article
                    generates: "app/decorators/article_decorator"
                               "spec/decorators/article_decorator_spec"
    DESC

    argument :resource_name, :type => :string
    class_option "test-framework", :type => :string, :default => "rspec", :aliases => "-t", :desc => "Test framework to be invoked"
    
    source_root File.expand_path('../templates', __FILE__)

    DECORATORS_ROOT = 'app/decorators/'

    def build_model_decorator
      template 'decorator.rb', "#{DECORATORS_ROOT}#{resource_name.singularize}_decorator.rb"
    end
#
    def build_decorator_tests
      case options["test-framework"]
        when "rspec"
          build_decorator_spec
        when "test_unit"
          build_decorator_test
      end
    end

    private
    def build_decorator_spec
      empty_directory 'spec/decorators'
      template 'decorator_spec.rb', File.join('spec/decorators', "#{resource_name.singularize}_decorator_spec.rb")
    end

    def build_decorator_test
      empty_directory 'test/decorators/'
      template 'decorator_test.rb', File.join('test/decorators', "#{resource_name.singularize}_decorator_test.rb")
    end

  end
end
