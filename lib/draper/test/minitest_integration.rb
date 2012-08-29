require 'draper/test/view_context'

MiniTest::Spec.register_spec_type(MiniTest::Spec::Decorator) do |desc|
  desc.superclass == Draper::Base
end
