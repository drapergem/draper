require "rails/generators"
require "rails/generators/rails/controller/controller_generator"
require "rails/generators/rails/scaffold_controller/scaffold_controller_generator"
require "rails/generators/model_helpers"

module Rails
  module Generators
    class ControllerGenerator
      include Rails::Generators::ModelHelpers

      class_option :model_name, type: :string, desc: "ModelName to be used"

      hook_for :decorator, type: :boolean, default: true do |generator|
        invoke generator, [options[:model_name] || name]
      end
    end

    class ScaffoldControllerGenerator
      hook_for :decorator, type: :boolean, default: true do |generator|
        invoke generator, [options[:model_name] || name]
      end
    end
  end
end
