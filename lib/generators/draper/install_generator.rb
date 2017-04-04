module Draper
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      desc 'Creates an ApplicationDecorator, if none exists.'

      def create_application_decorator
        file = 'app/decorators/application_decorator.rb'

        if File.exist? file
          say 'ApplicationDecorator found. Skipping...'
        else
          copy_file 'install.rb', file
        end
      end
    end
  end
end
