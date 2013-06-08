require "rails/generators"
require "rails/generators/rails/controller/controller_generator"
require "rails/generators/rails/scaffold_controller/scaffold_controller_generator"

module Rails
  module Generators
    class ControllerGenerator
      hook_for :decorator, default: true
    end

    class ScaffoldControllerGenerator
      hook_for :decorator, default: true
    end
  end
end
