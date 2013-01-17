require 'spec_helper'

module Draper
  describe DecoratedAssociation do

    describe "#initialize" do
      describe "options validation" do
        it "does not raise error on valid options" do
          valid_options = {with: Decorator, scope: :foo, context: {}}
          expect{DecoratedAssociation.new(Decorator.new(Model.new), :association, valid_options)}.not_to raise_error
        end

        it "raises error on invalid options" do
          expect{DecoratedAssociation.new(Decorator.new(Model.new), :association, foo: "bar")}.to raise_error ArgumentError, /Unknown key/
        end
      end
    end

    describe "#call" do
      let(:context) { {some: "context"} }
      let(:options) { {} }

      let(:decorated_association) do
        owner = double(context: nil, source: double(association: associated))

        DecoratedAssociation.new(owner, :association, options).tap do |decorated_association|
          decorated_association.stub context: context
        end
      end

      context "for a singular association" do
        let(:associated) { Model.new }

        context "when :with option was given" do
          let(:options) { {with: Decorator} }

          it "uses the specified decorator" do
            Decorator.should_receive(:decorate).with(associated, context: context).and_return(:decorated)
            expect(decorated_association.call).to be :decorated
          end
        end

        context "when :with option was not given" do
          it "infers the decorator" do
            associated.stub decorator_class: OtherDecorator

            OtherDecorator.should_receive(:decorate).with(associated, context: context).and_return(:decorated)
            expect(decorated_association.call).to be :decorated
          end
        end
      end

      context "for a collection association" do
        let(:associated) { [] }

        context "when :with option is a collection decorator" do
          let(:options) { {with: ProductsDecorator} }

          it "uses the specified decorator" do
            ProductsDecorator.should_receive(:decorate).with(associated, context: context).and_return(:decorated_collection)
            expect(decorated_association.call).to be :decorated_collection
          end
        end

        context "when :with option is a singular decorator" do
          let(:options) { {with: ProductDecorator} }

          it "uses a CollectionDecorator of the specified decorator" do
            ProductDecorator.should_receive(:decorate_collection).with(associated, context: context).and_return(:decorated_collection)
            expect(decorated_association.call).to be :decorated_collection
          end
        end

        context "when :with option was not given" do
          context "when the collection itself is decoratable" do
            before { associated.stub decorator_class: ProductsDecorator }

            it "infers the decorator" do
              ProductsDecorator.should_receive(:decorate).with(associated, context: context).and_return(:decorated_collection)
              expect(decorated_association.call).to be :decorated_collection
            end
          end

          context "when the collection is not decoratable" do
            it "uses a CollectionDecorator of inferred decorators" do
              CollectionDecorator.should_receive(:decorate).with(associated, context: context).and_return(:decorated_collection)
              expect(decorated_association.call).to be :decorated_collection
            end
          end
        end
      end

      context "with a scope" do
        let(:options) { {scope: :foo} }
        let(:associated) { double(foo: scoped) }
        let(:scoped) { Product.new }

        it "applies the scope before decoration" do
          expect(decorated_association.call.source).to be scoped
        end
      end
    end

    describe "#context" do
      let(:owner_context) { {some: "context"} }
      let(:options) { {} }
      let(:decorated_association) do
        owner = double(context: owner_context)
        DecoratedAssociation.new(owner, :association, options)
      end

      context "when :context option was given" do
        let(:options) { {context: context} }

        context "and is callable" do
          let(:context) { ->(*){ :dynamic_context } }

          it "calls it with the owner's context" do
            context.should_receive(:call).with(owner_context)
            decorated_association.context
          end

          it "returns the lambda's return value" do
            expect(decorated_association.context).to be :dynamic_context
          end
        end

        context "and is not callable" do
          let(:context) { {other: "context"} }

          it "returns the specified value" do
            expect(decorated_association.context).to be context
          end
        end
      end

      context "when :context option was not given" do
        it "returns the owner's context" do
          expect(decorated_association.context).to be owner_context
        end
      end
    end

  end
end
