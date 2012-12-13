require 'spec_helper'

describe Draper::DecoratedAssociation do
  let(:decorated_association) { Draper::DecoratedAssociation.new(base, association, options) }
  let(:source) { Product.new }
  let(:base) { source.decorate }
  let(:options) { {} }

  describe "#initialize" do
    describe "options validation" do
      let(:association) { :similar_products }
      let(:valid_options) { {with: ProductDecorator, scope: :foo, context: {}} }

      it "does not raise error on valid options" do
        expect { Draper::DecoratedAssociation.new(base, association, valid_options) }.to_not raise_error
      end

      it "raises error on invalid options" do
        expect { Draper::DecoratedAssociation.new(base, association, valid_options.merge(foo: 'bar')) }.to raise_error(ArgumentError, 'Invalid option keys: :foo')
      end
    end
  end

  describe "#base" do
    subject { decorated_association.base }
    let(:association) { :similar_products }

    it "returns the base decorator" do
      should be base
    end

    it "returns a Decorator" do
      subject.class.should == ProductDecorator
    end
  end

  describe "#source" do
    subject { decorated_association.source }
    let(:association) { :similar_products }

    it "returns the base decorator's source" do
      should be base.source
    end

    it "returns a Model" do
      subject.class.should == Product
    end
  end

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

    context "base has context" do
      let(:association) { :similar_products }
      let(:base) { source.decorate(context: {some: 'context'}) }

      context "when no context is specified" do
        it "it should inherit context from base" do
          subject.context.should == {some: 'context'}
        end

        it "it should share context hash with base" do
          subject.context.should be base.context
        end
      end

      context "when static context is specified" do
        let(:options) { {context: {other: 'context'}} }

        it "it should get context from static option" do
          subject.context.should == {other: 'context'}
        end
      end

      context "when lambda context is specified" do
        let(:options) { {context: lambda {|context| context.merge(other: 'protext')}} }

        it "it should get generated context" do
          subject.context.should == {some: 'context', other: 'protext'}
        end
      end
    end
  end

  describe "#decorator_options" do
    subject { decorated_association.send(:decorator_options) }

    context "collection association" do
      let(:association) { :similar_products }

      context "no options" do
        it "should return default options" do
          should == {with: :infer, context: {}}
        end

        it "should set with: to :infer" do
          decorated_association.send(:options).should == options
          subject
          decorated_association.send(:options).should == {with: :infer}
        end
      end

      context "option with: ProductDecorator" do
        let(:options) { {with: ProductDecorator} }
        it "should pass with: from options" do
          should == {with: ProductDecorator, context: {}}
        end
      end

      context "option scope: :to_a" do
        let(:options) { {scope: :to_a} }
        it "should strip scope: from options" do
          decorated_association.send(:options).should == options
          should == {with: :infer, context: {}}
        end
      end

      context "base has context" do
        let(:base) { source.decorate(context: {some: 'context'}) }

        context "no options" do
          it "should return context from base" do
            should == {with: :infer, context: {some: 'context'}}
          end
        end

        context "option context: {other: 'context'}" do
          let(:options) { {context: {other: 'context'}} }
          it "should return specified context" do
            should == {with: :infer, context: {other: 'context'}}
          end
        end

        context "option context: lambda" do
          let(:options) { {context: lambda {|context| context.merge(other: 'protext')}} }
          it "should return specified context" do
            should == {with: :infer, context: {some: 'context', other: 'protext'}}
          end
        end
      end
    end

    context "singular association" do
      let(:association) { :previous_version }

      context "no options" do
        it "should return default options" do
          should == {context: {}}
        end
      end

      context "option with: ProductDecorator" do
        let(:options) { {with: ProductDecorator} }
        it "should strip with: from options" do
          should == {context: {}}
        end
      end

      context "option scope: :decorate" do
        let(:options) { {scope: :decorate} }
        it "should strip scope: from options" do
          decorated_association.send(:options).should == options
          should == {context: {}}
        end
      end

      context "base has context" do
        let(:base) { source.decorate(context: {some: 'context'}) }

        context "no options" do
          it "should return context from base" do
            should == {context: {some: 'context'}}
          end
        end

        context "option context: {other: 'context'}" do
          let(:options) { {context: {other: 'context'}} }
          it "should return specified context" do
            should == {context: {other: 'context'}}
          end
        end

        context "option context: lambda" do
          let(:options) { {context: lambda {|context| context.merge(other: 'protext')}} }
          it "should return specified context" do
            should == {context: {some: 'context', other: 'protext'}}
          end
        end
      end
    end
  end
end
