require 'draper/test/view_context'

module MiniTest
  class Spec
    class Decorator < Spec
      before { Draper::ViewContext.infect!(self) }
    end
  end
end

class MiniTest::Unit::DecoratorTestCase < MiniTest::Unit::TestCase
  add_setup_hook { Draper::ViewContext.infect!(self) }
end

MiniTest::Spec.register_spec_type(MiniTest::Spec::Decorator) do |desc|
  desc.superclass == Draper::Base
end
