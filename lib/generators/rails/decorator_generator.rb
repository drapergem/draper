require File.expand_path('../../draper/decorator/decorator_generator.rb', __FILE__)
class Rails::DecoratorGenerator < Draper::DecoratorGenerator

  source_root File.expand_path('../../draper/decorator/templates', __FILE__)
end