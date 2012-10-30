require 'spec_helper'

describe Draper::Utils do
  describe ".decorators_of" do
    it "returns a list of decorators applied to a model" do
      instance = ProductDecorator.new(SpecificProductDecorator.new(Product.new))
      Draper::Utils.decorators_of(instance).should == [ProductDecorator, SpecificProductDecorator]
    end

    it "returns an empty array when instance is not decorated" do
      Draper::Utils.decorators_of(Product.new).should be_empty
    end
  end
end
