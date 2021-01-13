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
          decorated = CollectionDecorator.new([]).tap(&:to_a)
          undecorated = CollectionDecorator.new([])

          expect(decorated.instance_variable_defined?(:@decorated_collection)).to be_truthy
          expect(undecorated.instance_variable_defined?(:@decorated_collection)).to be_falsy
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

        decorator.zip collection do |item, object|
          expect(item.object).to be object
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

      it "defaults the :to option to :object" do
        expect(Object).to receive(:delegate).with(:foo, :bar, to: :object)
        ProductsDecorator.delegate :foo, :bar
      end

      it "does not overwrite the :to option if supplied" do
        expect(Object).to receive(:delegate).with(:foo, :bar, to: :baz)
        ProductsDecorator.delegate :foo, :bar, to: :baz
      end
    end

    describe "#find" do
      it "decorates Enumerable#find" do
        decorator = CollectionDecorator.new([])

        expect(decorator.decorated_collection).to receive(:find).and_return(:delegated)
        expect(decorator.find{|p| p.title == "title"}).to be :delegated
      end
    end

    describe "#to_ary" do
      # required for `render @collection` in Rails
      it "delegates to the decorated collection" do
        decorator = CollectionDecorator.new([])

        expect(decorator.decorated_collection).to receive(:to_ary).and_return(:delegated)
        expect(decorator.to_ary).to be :delegated
      end
    end

    it "delegates array methods to the decorated collection" do
      decorator = CollectionDecorator.new([])

      allow(decorator).to receive_message_chain(:decorated_collection, :[]).with(42).and_return(:delegated)
      expect(decorator[42]).to be :delegated
    end

    describe "#==" do
      context "when comparing to a collection decorator with the same object" do
        it "returns true" do
          object = [Product.new, Product.new]
          decorator = CollectionDecorator.new(object)
          other = ProductsDecorator.new(object)

          expect(decorator == other).to be_truthy
        end
      end

      context "when comparing to a collection decorator with a different object" do
        it "returns false" do
          decorator = CollectionDecorator.new([Product.new, Product.new])
          other = ProductsDecorator.new([Product.new, Product.new])

          expect(decorator == other).to be_falsey
        end
      end

      context "when comparing to a collection of the same items" do
        it "returns true" do
          object = [Product.new, Product.new]
          decorator = CollectionDecorator.new(object)
          other = object.dup

          expect(decorator == other).to be_truthy
        end
      end

      context "when comparing to a collection of different items" do
        it "returns false" do
          decorator = CollectionDecorator.new([Product.new, Product.new])
          other = [Product.new, Product.new]

          expect(decorator == other).to be_falsey
        end
      end

      context "when the decorated collection has been modified" do
        it "is no longer equal to the object" do
          object = [Product.new, Product.new]
          decorator = CollectionDecorator.new(object)
          other = object.dup

          decorator << Product.new.decorate
          expect(decorator == other).to be_falsey
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

          expect(decorator.to_s).to match(/ProductsDecorator/)
        end
      end
    end

    describe '#object' do
      it 'returns the underlying collection' do
        collection = [Product.new]
        decorator = ProductsDecorator.new(collection)

        expect(decorator.object).to eq collection
      end
    end

    describe '#decorated?' do
      it 'returns true' do
        decorator = ProductsDecorator.new([Product.new])

        expect(decorator).to be_decorated
      end
    end

    describe '#decorated_with?' do
      it "checks if a decorator has been applied to a collection" do
        decorator = ProductsDecorator.new([Product.new])

        expect(decorator).to be_decorated_with ProductsDecorator
        expect(decorator).not_to be_decorated_with OtherDecorator
      end
    end

    describe '#kind_of?' do
      it 'asks the kind of its decorated collection' do
        decorator = ProductsDecorator.new([])
        expect(decorator.decorated_collection).to receive(:kind_of?).with(Array).and_return("true")
        expect(decorator.kind_of?(Array)).to eq "true"
      end

      context 'when asking the underlying collection returns false' do
        it 'asks the CollectionDecorator instance itself' do
          decorator = ProductsDecorator.new([])
          allow(decorator.decorated_collection).to receive(:kind_of?).with(::Draper::CollectionDecorator).and_return(false)
          expect(decorator.kind_of?(::Draper::CollectionDecorator)).to be true
        end
      end
    end

    describe '#is_a?' do
      it 'aliases to #kind_of?' do
        decorator = ProductsDecorator.new([])
        expect(decorator.method(:kind_of?)).to eq decorator.method(:is_a?)
      end
    end

    describe "#replace" do
      it "replaces the decorated collection" do
        decorator = CollectionDecorator.new([Product.new])
        replacement = [:foo, :bar]

        decorator.replace replacement
        expect(decorator).to match_array replacement
      end

      it "returns itself" do
        decorator = CollectionDecorator.new([Product.new])

        expect(decorator.replace([:foo, :bar])).to be decorator
      end
    end
  end
end
