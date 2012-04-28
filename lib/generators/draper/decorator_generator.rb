module Draper
  module Generators
    class DecoratorGenerator < Rails::Generators::NamedBase
      source_root File.expand_path('../templates', __FILE__)

      desc <<-DESC
      Description:
          Generate a decorator for the given model.
          Example: rails g draper:decorator Article
                      generates: "app/decorators/article_decorator"
                                 "spec/decorators/article_decorator_spec"
      DESC

      def create_decorator_file
        template 'decorator.rb', File.join('app/decorators', "#{singular_name}_decorator.rb")
      end

      hook_for :test_framework
    end
  end
end
