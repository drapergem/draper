require 'minitest_helper'

def it_does_not_leak_view_context
  2.times do
    it "has an independent view context" do
      refute_equal :leaked, Draper::ViewContext.current
      Draper::ViewContext.current = :leaked
    end
  end
end

describe "A decorator test" do
  it_does_not_leak_view_context
end

describe "A controller test" do
  tests Class.new(ActionController::Base)

  it_does_not_leak_view_context
end

describe "A mailer test" do
  it_does_not_leak_view_context
end
