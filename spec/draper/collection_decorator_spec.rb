require 'spec_helper'
require 'support/shared_examples/view_helpers'

module Draper
  describe CollectionDecorator do
    it_behaves_like "view helpers", CollectionDecorator.new([])

    describe "#initialize" do
      describe "options validation" do

        it "does not raise error on valid options" do
          valid_options = {with: Decorator, context: {}}
          expect{CollectionDecorator.new([], valid_options)}.not_to raise_error
        end

        it "raises error on invalid options" do
          expect{CollectionDecorator.new([], foo: "bar")}.to raise_error ArgumentError, /Unknown key/
        end
      end
    end

    context "with context" do
      it "stores the context itself" do
        context = {some: "context"}
        decorator = CollectionDecorator.new([], context: context)

        expect(decorator.context).to be context
      end

      it "passes context to the individual decorators" do
        context = {some: "context"}
        decorator = CollectionDecorator.new([Product.new, Product.new], context: context)

        decorator.each do |item|
          expect(item.context).to be context
        end
      end
    end

    describe "with decorator namespace" do
      it "stores the namespace itself" do
        decorator = CollectionDecorator.new([], namespace: DecoratorNamespace)

        expect(decorator.decorator_namespace).to be DecoratorNamespace
      end

      it "passes the namespace to the individual decorators" do
        decorator = CollectionDecorator.new([Product.new, Product.new], namespace: DecoratorNamespace)

        decorator.each do |item|
          expect(item).to be_an_instance_of(DecoratorNamespace::ProductDecorator)
        end
      end
    end

    describe "#context=" do
      it "updates the stored context" do
        decorator = CollectionDecorator.new([], context: {some: "context"})
        new_context = {other: "context"}

        decorator.context = new_context
        expect(decorator.context).to be new_context
      end

      context "when the collection is already decorated" do
        it "updates the items' context" do
          decorator = CollectionDecorator.new([Product.new, Product.new], context: {some: "context"})
          decorator.decorated_collection # trigger decoration
          new_context = {other: "context"}

          decorator.context = new_context
          decorator.each do |item|
            expect(item.context).to be new_context
          end
        end
      end

      context "when the collection has not yet been decorated" do
        it "does not trigger decoration" do
          decorator = CollectionDecorator.new([])

          decorator.should_not_receive(:decorated_collection)
          decorator.context = {other: "context"}
        end

        it "sets context after decoration is triggered" do
          decorator = CollectionDecorator.new([Product.new, Product.new], context: {some: "context"})
          new_context = {other: "context"}

          decorator.context = new_context
          decorator.each do |item|
            expect(item.context).to be new_context
          end
        end
      end
    end

    describe "item decoration" do
      it "sets decorated items' source models" do
        collection = [Product.new, Product.new]
        decorator = CollectionDecorator.new(collection)

        decorator.zip collection do |item, source|
          expect(item.source).to be source
        end
      end

      context "when the :with option was given" do
        it "uses the :with option" do
          decorator = CollectionDecorator.new([Product.new], with: OtherDecorator).first

          expect(decorator).to be_decorated_with OtherDecorator
        end
      end

      context "when the :with option was not given" do
        it "infers the item decorator from each item" do
          decorator = CollectionDecorator.new([double(decorate: :inferred_decorator)]).first

          expect(decorator).to be :inferred_decorator
        end
      end
    end

    describe ".delegate" do
      protect_class ProductsDecorator

      it "defaults the :to option to :source" do
        Object.should_receive(:delegate).with(:foo, :bar, to: :source)
        ProductsDecorator.delegate :foo, :bar
      end

      it "does not overwrite the :to option if supplied" do
        Object.should_receive(:delegate).with(:foo, :bar, to: :baz)
        ProductsDecorator.delegate :foo, :bar, to: :baz
      end
    end

    describe "#find" do
      context "with a block" do
        it "decorates Enumerable#find" do
          decorator = CollectionDecorator.new([])

          decorator.decorated_collection.should_receive(:find).and_return(:delegated)
          expect(decorator.find{|p| p.title == "title"}).to be :delegated
        end
      end

      context "without a block" do
        it "decorates Model.find" do
          item_decorator = Class.new
          decorator = CollectionDecorator.new([], with: item_decorator)

          item_decorator.should_receive(:find).with(1).and_return(:delegated)
          expect(decorator.find(1)).to be :delegated
        end
      end
    end

    describe "#to_ary" do
      # required for `render @collection` in Rails
      it "delegates to the decorated collection" do
        decorator = CollectionDecorator.new([])

        decorator.decorated_collection.should_receive(:to_ary).and_return(:delegated)
        expect(decorator.to_ary).to be :delegated
      end
    end

    it "delegates array methods to the decorated collection" do
      decorator = CollectionDecorator.new([])

      decorator.decorated_collection.should_receive(:[]).with(42).and_return(:delegated)
      expect(decorator[42]).to be :delegated
    end

    describe "#==" do
      context "when comparing to a collection decorator with the same source" do
        it "returns true" do
          source = [Product.new, Product.new]
          decorator = CollectionDecorator.new(source)
          other = ProductsDecorator.new(source)

          expect(decorator == other).to be_true
        end
      end

      context "when comparing to a collection decorator with a different source" do
        it "returns false" do
          decorator = CollectionDecorator.new([Product.new, Product.new])
          other = ProductsDecorator.new([Product.new, Product.new])

          expect(decorator == other).to be_false
        end
      end

      context "when comparing to a collection of the same items" do
        it "returns true" do
          source = [Product.new, Product.new]
          decorator = CollectionDecorator.new(source)
          other = source.dup

          expect(decorator == other).to be_true
        end
      end

      context "when comparing to a collection of different items" do
        it "returns false" do
          decorator = CollectionDecorator.new([Product.new, Product.new])
          other = [Product.new, Product.new]

          expect(decorator == other).to be_false
        end
      end

      context "when the decorated collection has been modified" do
        it "is no longer equal to the source" do
          source = [Product.new, Product.new]
          decorator = CollectionDecorator.new(source)
          other = source.dup

          decorator << Product.new.decorate
          expect(decorator == other).to be_false
        end
      end
    end

    describe "#to_s" do
      context "when :with option was given" do
        it "returns a string representation of the collection decorator" do
          decorator = CollectionDecorator.new(["a", "b", "c"], with: ProductDecorator)

          expect(decorator.to_s).to eq '#<Draper::CollectionDecorator of ProductDecorator for ["a", "b", "c"]>'
        end
      end

      context "when :with option was not given" do
        it "returns a string representation of the collection decorator" do
          decorator = CollectionDecorator.new(["a", "b", "c"])

          expect(decorator.to_s).to eq '#<Draper::CollectionDecorator of inferred decorators for ["a", "b", "c"]>'
        end
      end

      context "for a custom subclass" do
        it "uses the custom class name" do
          decorator = ProductsDecorator.new([])

          expect(decorator.to_s).to match /ProductsDecorator/
        end
      end
    end

    describe '#decorated?' do
      it 'returns true' do
        decorator = ProductsDecorator.new([Product.new])

        expect(decorator).to be_decorated
      end
    end

  end
end
