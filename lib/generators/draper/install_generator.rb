module Draper
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      desc <<-DESC
      Description:
          Generate application and spec decorators in your application.
      DESC

      def create_decorator_file
        template 'application_decorator.rb', File.join('app/decorators', 'application_decorator.rb')
      end

      hook_for :test_framework, :as => :decorator do |test_framework|
        invoke test_framework, ['application']
      end
    end
  end
end
