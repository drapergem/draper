module Drapper
  class DecoratorGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)

    DECORATORS_ROOT = 'app/decorators/'
    APPLICATION_DECORATOR = 'application_decorator.rb'
    APPLICATION_DECORATOR_PATH = DECORATORS_ROOT + APPLICATION_DECORATOR

    def build_model_and_application_decorators
      empty_directory "app/decorators"
      unless File.exists?(APPLICATION_DECORATOR_PATH)
        template APPLICATION_DECORATOR, APPLICATION_DECORATOR_PATH
      end
      template 'decorator.rb', "#{DECORATORS_ROOT}#{singular_name}_decorator.rb"
    end
  end
end
