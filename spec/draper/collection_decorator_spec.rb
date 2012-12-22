require 'spec_helper'

describe Draper::CollectionDecorator do
  before { ApplicationController.new.view_context }
  subject { Draper::CollectionDecorator.new(source, with: ProductDecorator) }
  let(:source){ [Product.new, Product.new] }
  let(:non_active_model_source){ NonActiveModelProduct.new }

  it "decorates a collection's items" do
    subject.each do |item|
      item.should be_decorated_with ProductDecorator
    end
  end

  it "sets the decorated items' source models" do
    subject.map{|item| item.source}.should == source
  end

  context "with context" do
    subject { Draper::CollectionDecorator.new(source, with: ProductDecorator, context: {some: 'context'}) }

    its(:context) { should == {some: 'context'} }

    it "passes context to the individual decorators" do
      subject.each do |item|
        item.context.should == {some: 'context'}
      end
    end

    it "does not tie the individual decorators' contexts together" do
      subject.each do |item|
        item.context.should == {some: 'context'}
        item.context = {alt: 'context'}
        item.context.should == {alt: 'context'}
      end
    end

    describe "#context=" do
      it "updates the collection decorator's context" do
        subject.context = {other: 'context'}
        subject.context.should == {other: 'context'}
      end

      context "when the collection is already decorated" do
        it "updates the items' context" do
          subject.decorated_collection
          subject.context = {other: 'context'}
          subject.each do |item|
            item.context.should == {other: 'context'}
          end
        end
      end

      context "when the collection has not yet been decorated" do
        it "does not trigger decoration" do
          subject.should_not_receive(:decorated_collection)
          subject.context = {other: 'context'}
        end

        it "sets context after decoration is triggered" do
          subject.context = {other: 'context'}
          subject.each do |item|
            item.context.should == {other: 'context'}
          end
        end
      end
    end
  end

  describe "#initialize" do
    describe "options validation" do
      let(:valid_options) { {with: ProductDecorator, context: {}} }

      it "does not raise error on valid options" do
        expect { Draper::CollectionDecorator.new(source, valid_options) }.to_not raise_error
      end

      it "raises error on invalid options" do
        expect { Draper::CollectionDecorator.new(source, valid_options.merge(foo: 'bar')) }.to raise_error(ArgumentError, 'Unknown key: foo')
      end
    end
  end

  describe "#source" do
    it "returns the source collection" do
      subject.source.should be source
    end

    it "is aliased to #to_source" do
      subject.to_source.should be source
    end
  end

  describe "item decoration" do
    subject { subject_class.new(source, options) }
    let(:decorator_classes) { subject.decorated_collection.map(&:class) }
    let(:source) { [Product.new, Widget.new] }

    context "when the :with option was given" do
      let(:options) { {with: SpecificProductDecorator} }

      context "and the decorator can't be inferred from the class" do
        let(:subject_class) { Draper::CollectionDecorator }

        it "uses the :with option" do
          decorator_classes.should == [SpecificProductDecorator, SpecificProductDecorator]
        end
      end

      context "and the decorator is inferrable from the class" do
        let(:subject_class) { ProductsDecorator }

        it "uses the :with option" do
          decorator_classes.should == [SpecificProductDecorator, SpecificProductDecorator]
        end
      end
    end

    context "when the :with option was not given" do
      let(:options) { {} }

      context "and the decorator can't be inferred from the class" do
        let(:subject_class) { Draper::CollectionDecorator }

        it "infers the decorator from each item" do
          decorator_classes.should == [ProductDecorator, WidgetDecorator]
        end
      end

      context "and the decorator is inferrable from the class" do
        let(:subject_class) { ProductsDecorator}

        it "infers the decorator" do
          decorator_classes.should == [ProductDecorator, ProductDecorator]
        end
      end
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
    before { subject.helpers.should_receive(:localize).with(:an_object, {some: 'parameter'}) }

    it "delegates to helpers" do
      subject.localize(:an_object, some: 'parameter')
    end

    it "is aliased to #l" do
      subject.l(:an_object, some: 'parameter')
    end
  end

  describe ".helpers" do
    it "returns a HelperProxy" do
      subject.class.helpers.should be_a Draper::HelperProxy
    end

    it "is aliased to .h" do
      subject.class.h.should be subject.class.helpers
    end
  end

  describe "#to_ary" do
    # required for `render @collection` in Rails
    it "delegates to the decorated collection" do
      subject.decorated_collection.should_receive(:to_ary).and_return(:an_array)
      subject.to_ary.should == :an_array
    end
  end

  describe "#respond_to?" do
    it "returns true for its own methods" do
      subject.should respond_to :decorated_collection
    end

    it "returns true for the wrapped collection's methods" do
      source.stub(:respond_to?).with(:whatever, true).and_return(true)
      subject.respond_to?(:whatever, true).should be_true
    end
  end

  context "Array methods" do
    describe "#include?" do
      it "delegates to the decorated collection" do
        subject.decorated_collection.should_receive(:include?).with(:something).and_return(true)
        subject.should include :something
      end
    end

    describe "#[]" do
      it "delegates to the decorated collection" do
        subject.decorated_collection.should_receive(:[]).with(42).and_return(:something)
        subject[42].should == :something
      end
    end
  end

  describe "#==" do
    context "when comparing to a collection decorator with the same source" do
      it "returns true" do
        a = Draper::CollectionDecorator.new(source, with: ProductDecorator)
        b = ProductsDecorator.new(source)
        a.should == b
      end
    end

    context "when comparing to a collection decorator with a different source" do
      it "returns false" do
        a = Draper::CollectionDecorator.new(source, with: ProductDecorator)
        b = ProductsDecorator.new([Product.new])
        a.should_not == b
      end
    end

    context "when comparing to a collection of the same items" do
      it "returns true" do
        a = Draper::CollectionDecorator.new(source, with: ProductDecorator)
        b = source.dup
        a.should == b
      end
    end

    context "when comparing to a collection of different items" do
      it "returns true" do
        a = Draper::CollectionDecorator.new(source, with: ProductDecorator)
        b = [Product.new]
        a.should_not == b
      end
    end
  end

  it "pretends to be the source class" do
    subject.kind_of?(source.class).should be_true
    subject.is_a?(source.class).should be_true
  end

  it "is still its own class" do
    subject.kind_of?(subject.class).should be_true
    subject.is_a?(subject.class).should be_true
  end

  describe "#method_missing" do
    before do
      class << source
        def page_number
          42
        end
      end
    end

    it "proxies unknown methods to the source collection" do
      subject.page_number.should == 42
    end
  end

end
