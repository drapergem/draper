require 'spec_helper'

describe Draper::Decoratable do
  subject { Product.new }

  describe '#decorator' do
    its(:decorator) { should be_kind_of(ProductDecorator) }
    its(:decorator) { should be(subject.decorator) }

    it 'have abillity to pass block' do
      a = Product.new.decorator { |d| d.awesome_title }
      a.should eql "Awesome Title"
    end

    it 'is aliased to .decorate' do
      subject.decorator.model.should == subject.decorate.model
    end
  end

  describe "#applied_decorators" do
    it "returns an empty list" do
      subject.applied_decorators.should be_empty
    end
  end

  describe "#decorated_with?" do
    it "returns false" do
      subject.should_not be_decorated_with ProductDecorator
    end
  end

  describe "#decorated?" do
    it "returns false" do
      subject.should_not be_decorated
    end
  end

  describe "#decorator_class" do
    it "delegates to .decorator_class" do
      Product.stub(:decorator_class).and_return(WidgetDecorator)
      product = Product.new
      product.decorator_class.should be WidgetDecorator
    end
  end

  describe ".decorator_class" do
    context "for non-ActiveModel classes" do
      it "infers the decorator from the class" do
        NonActiveModelProduct.decorator_class.should be NonActiveModelProductDecorator
      end
    end

    context "for ActiveModel classes" do
      it "infers the decorator from the model name" do
        Product.stub(:model_name).and_return("Widget")
        Product.decorator_class.should be WidgetDecorator
      end
    end

    context "when the decorator can't be inferred" do
      it "throws an UninferrableDecoratorError" do
        expect{UninferrableDecoratorModel.decorator_class}.to raise_error Draper::UninferrableDecoratorError
      end
    end
  end

  describe Draper::Decoratable::ClassMethods do
    shared_examples_for "a call to Draper::Decoratable::ClassMethods#decorate" do
      subject { klass.limit }

      its(:decorate) { should be_kind_of(Draper::CollectionDecorator) }

      it "decorate the collection" do
        subject.decorate.size.should == 1
        subject.decorate.to_ary[0].model.should be_a(klass)
      end

      it "return a new instance each time it is called" do
        subject.decorate.should_not == subject.decorate
      end
    end

    describe '#decorate - decorate collections of AR objects' do
      let(:klass) { Product }

      it_should_behave_like "a call to Draper::Decoratable::ClassMethods#decorate"
    end

    describe '#decorate - decorate collections of namespaced AR objects' do
      let(:klass) { Namespace::Product }

      it_should_behave_like "a call to Draper::Decoratable::ClassMethods#decorate"
    end
  end
end
