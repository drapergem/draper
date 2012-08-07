require 'draper/test/view_context'

module MiniTest
  class Spec
    class Decorator < Spec
      before { Draper::ViewContext.infect!(self) }
    end
  end
end

class MiniTest::Unit::DecoratorTestCase < MiniTest::Unit::TestCase
  if method_defined?(:before_setup)
    # for minitext >= 2.11
    def before_setup
      super
      Draper::ViewContext.infect!(self)
    end
  else
    # for older minitest, like what ships w/Ruby 1.9
    add_setup_hook { Draper::ViewContext.infect!(self) }
  end
end

MiniTest::Spec.register_spec_type(MiniTest::Spec::Decorator) do |desc|
  desc.superclass == Draper::Base
end
