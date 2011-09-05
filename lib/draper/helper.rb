module Draper
  class Helper < ActionController::Base
    attr_accessor :controller
    include ActionView::Helpers

    def setup(controller)
      self.controller = controller
      self.env = controller.env
      self.request = controller.request
    end
  end
end
