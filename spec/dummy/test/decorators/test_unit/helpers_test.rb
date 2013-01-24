require 'test_helper'

class HelpersTest < Draper::TestCase
  def test_access_helpers_through_helper
    assert_equal "<p>Help!</p>", helper.content_tag(:p, "Help!")
  end

  def test_access_helpers_through_helpers
    assert_equal "<p>Help!</p>", helpers.content_tag(:p, "Help!")
  end

  def test_access_helpers_through_h
    assert_equal "<p>Help!</p>", h.content_tag(:p, "Help!")
  end

  def test_same_helper_object_as_decorators
    decorator = Draper::Decorator.new(Object.new)

    assert_same decorator.helpers, helpers
  end
end
