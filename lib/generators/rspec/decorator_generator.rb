module Rspec
  class DecoratorGenerator < ::Rails::Generators::NamedBase
    source_root File.expand_path('../templates', __FILE__)

    SPEC_ROOT = 'spec/decorators/'

    def build_model_and_application_decorator_specs
      template 'decorator_spec.rb', "#{SPEC_ROOT}#{singular_name}_decorator_spec.rb"
    end
  end
end
