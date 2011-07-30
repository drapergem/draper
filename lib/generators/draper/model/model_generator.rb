module Draper
  class ModelGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)

    def build_model_and_application_decorators
      empty_directory "app/decorators"
      template 'application_decorator.rb', 'app/decorators/application_decorator.rb'
      template 'model.rb', "app/decorators/#{singular_name}_decorator.rb"
    end
  end
end