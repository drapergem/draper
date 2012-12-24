require 'spec_helper'

describe Draper::Decoratable do
  subject { Product.new }

  describe "#decorate" do
    it "returns a decorator for self" do
     subject.decorate.should be_a ProductDecorator
     subject.decorate.source.should be subject
   end

    it "accepts context" do
      decorator = subject.decorate(context: {some: 'context'})
      decorator.context.should == {some: 'context'}
    end

    it "is not memoized" do
      subject.decorate.should_not be subject.decorate
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

  describe "#==" do
    context "with itself" do
      it "returns true" do
        (subject == subject).should be_true
      end
    end

    context "with another instance" do
      it "returns false" do
        (subject == Product.new).should be_false
      end
    end

    context "with a decorated version of itself" do
      it "returns true" do
        decorator = double(source: subject)
        (subject == decorator).should be_true
      end
    end

    context "with a decorated other instance" do
      it "returns false" do
        decorator = double(source: Product.new)
        (subject == decorator).should be_false
      end
    end
  end

  describe "#===" do
    context "with itself" do
      it "returns true" do
        (subject === subject).should be_true
      end
    end

    context "with another instance" do
      it "returns false" do
        (subject === Product.new).should be_false
      end
    end

    context "with a decorated version of itself" do
      it "returns true" do
        decorator = double(source: subject)
        (subject === decorator).should be_true
      end
    end

    context "with a decorated other instance" do
      it "returns false" do
        decorator = double(source: Product.new)
        (subject === decorator).should be_false
      end
    end
  end

  describe ".====" do
    context "with an instance" do
      it "returns true" do
        (Product === Product.new).should be_true
      end
    end

    context "with a derived instance" do
      it "returns true" do
        (Product === Widget.new).should be_true
      end
    end

    context "with an unrelated instance" do
      it "returns false" do
        (Product === Object.new).should be_false
      end
    end

    context "with a decorated instance" do
      it "returns true" do
        decorator = double(source: Product.new)
        (Product === decorator).should be_true
      end
    end

    context "with a decorated derived instance" do
      it "returns true" do
        decorator = double(source: Widget.new)
        (Product === decorator).should be_true
      end
    end

    context "with a decorated unrelated instance" do
      it "returns false" do
        decorator = double(source: Object.new)
        (Product === decorator).should be_false
      end
    end
  end

  describe ".decorate" do
    it "returns a collection decorator" do
      Product.stub(:scoped).and_return([Product.new])
      Product.stub(:decorator_class).and_return(WidgetDecorator)
      decorator = Product.decorate

      decorator.should be_a Draper::CollectionDecorator
      decorator.decorator_class.should be WidgetDecorator
      decorator.source.should == Product.scoped
    end

    it "accepts context" do
      decorator = Product.decorate(context: {some: 'context'})
      decorator.context.should == {some: 'context'}
    end

    it "is not memoized" do
      Product.decorate.should_not be Product.decorate
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

    context "for namespaced ActiveModel classes" do
      it "infers the decorator from the model name" do
        Namespace::Product.decorator_class.should be Namespace::ProductDecorator
      end
    end

    context "when the decorator can't be inferred" do
      it "throws an UninferrableDecoratorError" do
        expect{UninferrableDecoratorModel.decorator_class}.to raise_error Draper::UninferrableDecoratorError
      end
    end
  end
end
