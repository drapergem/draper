module Rspec
  class DecoratorGenerator < ::Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)

    SPEC_ROOT = 'spec/decorators/'
    APPLICATION_DECORATOR_SPEC = 'application_decorator_spec.rb'
    APPLICATION_DECORATOR_SPEC_PATH = SPEC_ROOT + APPLICATION_DECORATOR_SPEC

    def build_model_and_application_decorator_specs
      empty_directory SPEC_ROOT
      unless File.exists?(APPLICATION_DECORATOR_SPEC_PATH)
        template APPLICATION_DECORATOR_SPEC, APPLICATION_DECORATOR_SPEC_PATH
      end
      template 'decorator_spec.rb', "#{SPEC_ROOT}#{singular_name}_decorator_spec.rb"
    end
  end
end
