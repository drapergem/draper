require 'minitest_helper'

describe "A decorator test" do
  it "can access helpers through `helper`" do
    assert_equal "<p>Help!</p>", helper.content_tag(:p, "Help!")
  end

  it "can access helpers through `helpers`" do
    assert_equal "<p>Help!</p>", helpers.content_tag(:p, "Help!")
  end

  it "can access helpers through `h`" do
    assert_equal "<p>Help!</p>", h.content_tag(:p, "Help!")
  end

  it "gets the same helper object as a decorator" do
    decorator = Draper::Decorator.new(Object.new)

    assert_same decorator.helpers, helpers
  end
end
