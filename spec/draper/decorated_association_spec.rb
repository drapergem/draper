require 'spec_helper'

describe Draper::DecoratedAssociation do
  let(:decorated_association) { Draper::DecoratedAssociation.new(source, association, options) }
  let(:source) { Product.new }
  let(:options) { {} }

  describe "#call" do
    subject { decorated_association.call }

    context "for an ActiveModel collection association" do
      let(:association) { :similar_products }

      context "when the association is not empty" do
        it "decorates the collection" do
          subject.should be_a Draper::CollectionDecorator
        end

        it "infers the decorator" do
          subject.decorator_class.should be :infer
        end
      end

      context "when the association is empty" do
        it "returns an empty collection decorator" do
          source.stub(:similar_products).and_return([])
          subject.should be_a Draper::CollectionDecorator
          subject.should be_empty
          subject.first.should be_nil
        end
      end
    end

    context "for non-ActiveModel collection associations" do
      let(:association) { :poro_similar_products }

      context "when the association is not empty" do
        it "decorates the collection" do
          subject.should be_a Draper::CollectionDecorator
        end

        it "infers the decorator" do
          subject.decorator_class.should be :infer
        end
      end

      context "when the association is empty" do
        it "returns an empty collection decorator" do
          source.stub(:poro_similar_products).and_return([])
          subject.should be_a Draper::CollectionDecorator
          subject.should be_empty
          subject.first.should be_nil
        end
      end
    end

    context "for an ActiveModel singular association" do
      let(:association) { :previous_version }

      context "when the association is present" do
        it "decorates the association" do
          subject.should be_decorated_with ProductDecorator
        end
      end

      context "when the association is absent" do
        it "doesn't decorate the association" do
          source.stub(:previous_version).and_return(nil)
          subject.should be_nil
        end
      end
    end

    context "for a non-ActiveModel singular association" do
      let(:association) { :poro_previous_version }

      context "when the association is present" do
        it "decorates the association" do
          subject.should be_decorated_with ProductDecorator
        end
      end

      context "when the association is absent" do
        it "doesn't decorate the association" do
          source.stub(:poro_previous_version).and_return(nil)
          subject.should be_nil
        end
      end
    end

    context "when a decorator is specified" do
      let(:options) { {with: SpecificProductDecorator} }

      context "for a singular association" do
        let(:association) { :previous_version }

        it "decorates with the specified decorator" do
          subject.should be_decorated_with SpecificProductDecorator
        end
      end

      context "for a collection association" do
        let(:association) { :similar_products}

        it "decorates with a collection of the specifed decorators" do
          subject.should be_a Draper::CollectionDecorator
          subject.decorator_class.should be SpecificProductDecorator
        end
      end
    end

    context "when a collection decorator is specified" do
      let(:association) { :similar_products }
      let(:options) { {with: ProductsDecorator} }

      it "decorates with the specified decorator" do
        subject.should be_a ProductsDecorator
      end
    end

    context "with a scope" do
      let(:association) { :thing }
      let(:options) { {scope: :foo} }

      it "applies the scope before decoration" do
        scoped = [SomeThing.new]
        SomeThing.any_instance.should_receive(:foo).and_return(scoped)
        subject.source.should be scoped
      end
    end
  end
end
