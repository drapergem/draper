require File.expand_path('../../draper/decorator/decorator_generator.rb', __FILE__)
class Rails::DecoratorGenerator < Draper::DecoratorGenerator

  source_root File.expand_path('../../draper/decorator/templates', __FILE__)

  class_option :invoke_after_finished, :type => :string, :description => "Generator to invoke when finished"

  def build_model_and_application_decorators
    super
    if self.options[:invoke_after_finished]
      Rails::Generators.invoke(self.options[:invoke_after_finished], [@name, @_initializer.first[1..-1]])
    end
  end

end
