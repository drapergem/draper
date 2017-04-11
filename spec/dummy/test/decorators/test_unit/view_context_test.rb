require 'test_helper'

def it_does_not_leak_view_context
  2.times do |n|
    define_method("test_has_independent_view_context_#{n}") do
      refute_equal :leaked, Draper::ViewContext.current
      Draper::ViewContext.current = :leaked
    end
  end
end

class DecoratorTest < Draper::TestCase
  it_does_not_leak_view_context
end

class ControllerTest < ActionController::TestCase
  subject{ Class.new(ActionController::Base) }

  it_does_not_leak_view_context
end

class MailerTest < ActionMailer::TestCase
  it_does_not_leak_view_context
end
