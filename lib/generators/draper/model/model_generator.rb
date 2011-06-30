module Draper
  class ModelGenerator < Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)

    def build_model
      empty_directory "app/decorators"
      template 'model.rb', "app/decorators/#{singular_name}_decorator.rb"
    end
  end
end