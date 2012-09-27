class MiniTest::Rails::ActiveSupport::TestCase
  # Use AS::TestCase for the base class when describing a decorator
  register_spec_type(self) do |desc|
    desc < Draper::Base if desc.is_a?(Class)
  end
  register_spec_type(/Decorator( ?Test)?\z/i, self)
end
