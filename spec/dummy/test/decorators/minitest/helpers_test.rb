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
end
