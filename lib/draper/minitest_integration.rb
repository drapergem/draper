MiniTest::Spec.register_spec_type(MiniTest::Spec::Decorator) do |desc|
  desc.superclass == Draper::Base
end

module MiniTest
  module Spec
    class Decorator < Spec
      before :each do
          ApplicationController.new.set_current_view_context
          Draper::ViewContext.current.controller.request ||= ActionController::TestRequest.new
          Draper::ViewContext.current.request            ||= Draper::ViewContext.current.controller.request
          Draper::ViewContext.current.params             ||= {}
      end
    end
  end
end

class MiniTest::Unit
  before :each do
    ApplicationController.new.set_current_view_context
    Draper::ViewContext.current.controller.request ||= ActionController::TestRequest.new
    Draper::ViewContext.current.request            ||= Draper::ViewContext.current.controller.request
    Draper::ViewContext.current.params             ||= {}
  end
end
