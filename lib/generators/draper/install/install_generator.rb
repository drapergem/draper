module Draper
  class InstallGenerator < Rails::Generators::Base
    
    desc <<-DESC
    Description:
        Generate application and spec decorators in your application.
    DESC
    
    class_option "test-framework", :type => :string, :default => "rspec", :aliases => "-t", :desc => "Test framework to be invoked"
    
    source_root File.expand_path('../templates', __FILE__)

    def build_application_decorator
      empty_directory 'app/decorators'
      template 'application_decorator.rb', File.join('app/decorators', 'application_decorator.rb')
    end
    
    def build_decorator_tests
      case options["test-framework"]
        when "rspec"
          build_application_decorator_spec
        when "test_unit"
          build_application_decorator_test
      end
    end
    
    private
    def build_application_decorator_spec
      empty_directory 'spec/decorators'
      template 'application_decorator_spec.rb', File.join('spec/decorators', 'application_decorator_spec.rb')
    end
    
    def build_application_decorator_test
      empty_directory 'test/decorators/'
      template 'application_decorator_test.rb', File.join('test/decorators', 'application_decorator_test.rb')
    end

  end
end