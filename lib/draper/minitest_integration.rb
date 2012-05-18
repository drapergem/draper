require 'minitest/unit'
require 'minitest/spec'

module MiniTest
  class DecoratorSpec < Spec
    before do
      ApplicationController.new.set_current_view_context
      Draper::ViewContext.current.controller.request ||= ActionController::TestRequest.new
      Draper::ViewContext.current.request            ||= Draper::ViewContext.current.controller.request
      Draper::ViewContext.current.params             ||= {}
    end
  end
end

class MiniTest::Unit::DecoratorTestCase < MiniTest::Unit::TestCase
  add_setup_hook do
    ApplicationController.new.set_current_view_context
    Draper::ViewContext.current.controller.request ||= ActionController::TestRequest.new
    Draper::ViewContext.current.request            ||= Draper::ViewContext.current.controller.request
    Draper::ViewContext.current.params             ||= {}
  end
end

MiniTest::Spec.register_spec_type(MiniTest::DecoratorSpec) do |desc|
  desc.superclass == Draper::Base
end
