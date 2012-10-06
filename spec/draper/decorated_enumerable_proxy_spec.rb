require 'spec_helper'

describe Draper::DecoratedEnumerableProxy do
  before(:each){ ApplicationController.new.view_context }
  subject{ ProductsDecorator.new(source, ProductDecorator) }
  let(:source){ Product.new }
  let(:non_active_model_source){ NonActiveModelProduct.new }

  context(".helpers") do
    it "have a valid view_context" do
      subject.helpers.should be
    end

    it "is aliased to .h" do
      subject.h.should == subject.helpers
    end

    it "build a new view context" do
      Thread.current[:current_view_context] = nil
      subject.helpers.should be
    end
  end

  context(".decorates") do
    it "sets the model for the decorated" do
      EnumerableProxy.new([source], ProductDecorator).first.model.should == source
    end

    it "decorates an empty array with the class" do
      EnumerableProxy.decorates([], class: ProductDecorator).should be
    end

    it "discerns collection items decorator by the name of the decorator" do
      ProductsDecorator.decorates([]).should be
    end

    it "methods in decorated empty array should work" do
      ProductsDecorator.decorates([]).some_method.should == "some method works"
    end

    it "raises when decorates an empty array without the klass" do
      lambda{EnumerableProxy.decorates([])}.should raise_error
    end
  end
end
