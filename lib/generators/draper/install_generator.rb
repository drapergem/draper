module Draper
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      desc 'Creates an ApplicationDecorator, if none exists.'

      def create_application_decorator
        file = 'application_decorator.rb'
        path = "app/decorators/#{file}"
        copy_file file, path
      end
    end
  end
end
