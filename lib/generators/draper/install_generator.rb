module Draper
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      desc 'Creates an ApplicationDecorator, if none exists.'

      def create_application_decorator
        file = 'application_decorator.rb'
        copy_file file, "app/decorators/#{file}"
      end
    end
  end
end
