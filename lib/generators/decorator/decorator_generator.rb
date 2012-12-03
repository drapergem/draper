module Rails
  module Generators
   class DecoratorGenerator < NamedBase
      source_root File.expand_path("../templates", __FILE__)
      check_class_collision :suffix => "Decorator"

      class_option :parent, :type => :string, :desc => "The parent class for the generated decorator"

      def create_decorator_file
        template 'decorator.rb', File.join('app/decorators', class_path, "#{file_name}_decorator.rb")
      end

      hook_for :test_framework

      private

      def parent_class_name
        if options[:parent]
          options[:parent]
        elsif defined?(ApplicationDecorator)
          "ApplicationDecorator"
        else
          "Draper::Decorator"
        end
      end

      	
      # Rails 3.0.X compatibility, stolen from https://github.com/jnunemaker/mongomapper/pull/385/files#L1R32
      unless methods.include?(:module_namespacing)
        def module_namespacing(&block)
          yield if block
        end
      end
    end
  end
end
