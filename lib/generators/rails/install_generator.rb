module Rails
  module Generators
    class InstallGenerator < NamedBase
      source_root File.expand_path('../templates', __FILE__)

      desc 'Creates an ApplicationDecorator, if none exists.'

      def create_application_decorator
        file = 'app/decorators/application_decorator.rb'

        if File.exist? file
          say 'ApplicationDecorator found. Skipping...'
        else
          template 'install.rb', file
        end
      end
    end
  end
end
