module ActionController
  class Base
    Draper.setup_action_controller(self)
  end
end

class ApplicationController < ActionController::Base
  def hello_world
    "Hello, World!"
  end
  helper_method :hello_world
end
