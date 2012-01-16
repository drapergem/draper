module Draper
  class DecoratorGenerator < Rails::Generators::NamedBase
    desc <<-DESC
    Description:
        Generate a decorator for the given model.
        Example: rails g draper:decorator Article
                    generates: "app/decorators/article_decorator"
                               "spec/decorators/article_decorator_spec"
    DESC
    
    source_root File.expand_path('../templates', __FILE__)

    DECORATORS_ROOT = 'app/decorators/'

    def build_model_decorator
      template 'decorator.rb', "#{DECORATORS_ROOT}#{singular_name}_decorator.rb"
    end

    hook_for :test_framework
  end
end
