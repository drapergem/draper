require File.expand_path('../../config/environment', __FILE__)
require 'minitest/autorun'
require 'minitest/rails'

def it_is_a_decorator_test
  it "is a decorator test" do
    assert_kind_of Draper::TestCase, self
  end
end

def it_is_not_a_decorator_test
  it "is not a decorator test" do
    refute_kind_of Draper::TestCase, self
  end
end

ProductDecorator = Class.new(Draper::Decorator)
ProductsDecorator = Class.new(Draper::CollectionDecorator)

describe ProductDecorator do
  it_is_a_decorator_test
end

describe ProductsDecorator do
  it_is_a_decorator_test
end

describe "ProductDecorator" do
  it_is_a_decorator_test
end

describe "AnyDecorator" do
  it_is_a_decorator_test
end

describe "Any decorator test" do
  it_is_a_decorator_test
end

describe Object do
  it_is_not_a_decorator_test
end

describe "Nope" do
  it_is_not_a_decorator_test
end
