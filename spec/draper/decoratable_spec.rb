require 'spec_helper'
require 'support/shared_examples/decoratable_equality'

module Draper
  describe Decoratable do

    describe "#decorate" do
      it "returns a decorator for self" do
        product = Product.new
        decorator = product.decorate

        expect(decorator).to be_a ProductDecorator
        expect(decorator.source).to be product
     end

      it "accepts context" do
        context = {some: "context"}
        decorator = Product.new.decorate(context: context)

        expect(decorator.context).to be context
      end

      it "uses the #decorator_class" do
        product = Product.new
        product.stub decorator_class: OtherDecorator

        expect(product.decorate).to be_an_instance_of OtherDecorator
      end
    end

    describe "#applied_decorators" do
      it "returns an empty list" do
        expect(Product.new.applied_decorators).to eq []
      end
    end

    describe "#decorated_with?" do
      it "returns false" do
        expect(Product.new).not_to be_decorated_with Decorator
      end
    end

    describe "#decorated?" do
      it "returns false" do
        expect(Product.new).not_to be_decorated
      end
    end

    describe "#decorator_class" do
      it "delegates to .decorator_class" do
        product = Product.new

        Product.should_receive(:decorator_class).and_return(:some_decorator)
        expect(product.decorator_class).to be :some_decorator
      end
    end

    describe "#==" do
      it_behaves_like "decoration-aware #==", Product.new
    end

    describe "#===" do
      it "is true when #== is true" do
        product = Product.new

        product.should_receive(:==).and_return(true)
        expect(product === :anything).to be_true
      end

      it "is false when #== is false" do
        product = Product.new

        product.should_receive(:==).and_return(false)
        expect(product === :anything).to be_false
      end
    end

    describe ".====" do
      it "is true for an instance" do
        expect(Product === Product.new).to be_true
      end

      it "is true for a derived instance" do
        expect(Product === Class.new(Product).new).to be_true
      end

      it "is false for an unrelated instance" do
        expect(Product === Model.new).to be_false
      end

      it "is true for a decorated instance" do
        decorator = double(source: Product.new)

        expect(Product === decorator).to be_true
      end

      it "is true for a decorated derived instance" do
        decorator = double(source: Class.new(Product).new)

        expect(Product === decorator).to be_true
      end

      it "is false for a decorated unrelated instance" do
        decorator = double(source: Model.new)

        expect(Product === decorator).to be_false
      end
    end

    describe ".decorate" do
      it "calls #decorate_collection on .decorator_class" do
        scoped = [Product.new]
        Product.stub scoped: scoped

        Product.decorator_class.should_receive(:decorate_collection).with(scoped, {}).and_return(:decorated_collection)
        expect(Product.decorate).to be :decorated_collection
      end

      it "accepts options" do
        options = {context: {some: "context"}}
        Product.stub scoped: []

        Product.decorator_class.should_receive(:decorate_collection).with([], options)
        Product.decorate(options)
      end
    end

    describe ".decorator_class" do
      context "for classes" do
        it "infers the decorator from the class" do
          expect(Product.decorator_class).to be ProductDecorator
        end
      end

      context "for ActiveModel classes" do
        it "infers the decorator from the model name" do
          Product.stub(:model_name).and_return("Other")

          expect(Product.decorator_class).to be OtherDecorator
        end
      end

      context "in a namespace" do
        context "for classes" do
          it "infers the decorator from the class" do
            expect(Namespaced::Product.decorator_class).to be Namespaced::ProductDecorator
          end
        end

        context "for ActiveModel classes" do
          it "infers the decorator from the model name" do
            Namespaced::Product.stub(:model_name).and_return("Namespaced::Other")

            expect(Namespaced::Product.decorator_class).to be Namespaced::OtherDecorator
          end
        end
      end

      context "when the decorator can't be inferred" do
        it "throws an UninferrableDecoratorError" do
          expect{Model.decorator_class}.to raise_error UninferrableDecoratorError
        end
      end
    end

  end
end
