require 'spec_helper'

describe Draper::CollectionDecorator do
  before { ApplicationController.new.view_context }
  subject { Draper::CollectionDecorator.new(source, with: ProductDecorator) }
  let(:source){ [Product.new, Product.new] }
  let(:non_active_model_source){ NonActiveModelProduct.new }

  it "decorates a collection's items" do
    subject.each {|item| item.should be_decorated_with ProductDecorator }
  end

  it "sets the decorated items' source models" do
    subject.map{|item| item.source}.should == source
  end

  describe "#source" do
    it "returns the source collection" do
      subject.source.should be source
    end
  end

  describe "#find" do
    context "with a block" do
      it "decorates Enumerable#find" do
        subject.decorated_collection.should_receive(:find)
        subject.find {|p| p.title == "title" }
      end
    end

    context "without a block" do
      it "decorates Model.find" do
        source.should_not_receive(:find)
        Product.should_receive(:find).with(1).and_return(:product)
        subject.find(1).should == ProductDecorator.new(:product)
      end
    end
  end

  describe "#helpers" do
    it "returns a HelperProxy" do
      subject.helpers.should be_a Draper::HelperProxy
    end

    it "is aliased to #h" do
      subject.h.should be subject.helpers
    end

    it "initializes the wrapper only once" do
      helper_proxy = subject.helpers
      helper_proxy.stub(:test_method) { "test_method" }
      subject.helpers.test_method.should == "test_method"
      subject.helpers.test_method.should == "test_method"
    end
  end

  describe "#localize" do
    before { subject.helpers.should_receive(:localize).with(:an_object, {some: "options"}) }

    it "delegates to helpers" do
      subject.localize(:an_object, some: "options")
    end

    it "is aliased to #l" do
      subject.l(:an_object, some: "options")
    end
  end

  describe ".helpers" do
    it "returns a HelperProxy" do
      Decorator.helpers.should be_a Draper::HelperProxy
    end

    it "is aliased to .h" do
      Decorator.h.should be Decorator.helpers
    end
  end

  describe ".decorate" do
    it "decorates an empty array with the class" do
      EnumerableProxy.decorate([], with: ProductDecorator).should be
    end

    it "discerns collection items decorator by the name of the decorator" do
      ProductsDecorator.decorate([]).should be
    end

    it "methods in decorated empty array should work" do
      ProductsDecorator.decorate([]).some_method.should == "some method works"
    end

    it "raises when decorates an empty array without the klass" do
      expect{EnumerableProxy.decorate([])}.to raise_error Draper::UninferrableDecoratorError
    end
  end

  describe "collection decoration" do

    # Implementation of #decorate that returns an array
    # of decorated objects is insufficient to deal with
    # situations where the original collection has been
    # expanded with the use of modules (as often the case
    # with paginator gems) or is just more complex then
    # an array.
    module Paginator; def page_number; "magic_value"; end; end
    Array.send(:include, Paginator)
    let(:paged_array) { [Product.new, Product.new] }
    let(:empty_collection) { [] }
    subject { ProductDecorator.decorate(paged_array) }

    it "proxy all calls to decorated collection" do
      paged_array.page_number.should == "magic_value"
      subject.page_number.should == "magic_value"
    end

    it "support Rails partial lookup for a collection" do
      # to support Rails render @collection the returned collection
      # (or its proxy) should implement #to_ary.
      subject.respond_to?(:to_ary).should be true
      subject.to_ary.first.should == ProductDecorator.decorate(paged_array.first)
    end

    it "delegate respond_to? to the wrapped collection" do
      decorator = ProductDecorator.decorate(paged_array)
      paged_array.should_receive(:respond_to?).with(:whatever, true)
      decorator.respond_to?(:whatever, true)
    end

    it "return blank for a decorated empty collection" do
      # This tests that respond_to? is defined for the CollectionDecorator
      # since activesupport calls respond_to?(:empty) in #blank
      decorator = ProductDecorator.decorate(empty_collection)
      decorator.should be_blank
    end

    it "return whether the member is in the array for a decorated wrapped collection" do
      # This tests that include? is defined for the CollectionDecorator
      member = paged_array.first
      subject.respond_to?(:include?)
      subject.include?(member).should == true
      subject.include?(subject.first).should == true
      subject.include?(Product.new).should == false
    end

    it "equal each other when decorating the same collection" do
      subject_one = ProductDecorator.decorate(paged_array)
      subject_two = ProductDecorator.decorate(paged_array)
      subject_one.should == subject_two
    end

    it "not equal each other when decorating different collections" do
      subject_one = ProductDecorator.decorate(paged_array)
      new_paged_array = paged_array + [Product.new]
      subject_two = ProductDecorator.decorate(new_paged_array)
      subject_one.should_not == subject_two
    end

    it "allow decorated access by index" do
      subject = ProductDecorator.decorate(paged_array)
      subject[0].should be_instance_of ProductDecorator
    end

    context "pretends to be of kind of wrapped collection class" do
      subject { ProductDecorator.decorate(paged_array) }

      it "#kind_of? CollectionDecorator" do
        subject.should be_kind_of Draper::CollectionDecorator
      end

      it "#is_a? CollectionDecorator" do
        subject.is_a?(Draper::CollectionDecorator).should be_true
      end

      it "#kind_of? Array" do
        subject.should be_kind_of Array
      end

      it "#is_a? Array" do
        subject.is_a?(Array).should be_true
      end
    end

    context(".source / .to_source") do
      it "return the wrapped object" do
        subject.to_source == source
        subject.source == source
      end
    end
  end

end
