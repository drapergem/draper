require 'spec_helper'

describe Draper::ModelSupport do
  subject { Product.new }

  describe '#decorator' do
    its(:decorator) { should be_kind_of(ProductDecorator) }
    its(:decorator) { should be(subject.decorator) }

    it 'should have abillity to pass block' do
      a = Product.new.decorator { |d| d.awesome_title }
      a.should eql "Awesome Title"
    end

    it 'should be aliased to .decorate' do
      subject.decorator.model.should == subject.decorate.model
    end
  end

  describe Draper::ModelSupport::ClassMethods do
    shared_examples_for "a method that creates a DecoratedEnumerableProxy" do
      its(:decorate) { should be_kind_of(Draper::DecoratedEnumerableProxy) }

      it "should decorate the collection" do
        subject.decorate.size.should == 1
        subject.decorate.to_ary[0].model.should be_a(subject)
      end
    end

    shared_examples_for "a method that decorates an AR model class" do
      it "should call ::scoped" do
        subject.should_receive(:scoped)
        subject.decorate
      end

      it_should_behave_like "a method that creates a DecoratedEnumerableProxy"
    end

    describe '#decorate - decorate an AR model class' do
      subject { Product }

      it_should_behave_like "a method that decorates an AR model class"
    end

    describe '#decorate - decorate a namespaced AR model class' do
      subject { Namespace::Product }

      it_should_behave_like "a method that decorates an AR model class"
    end

    shared_examples_for "a method that decorates a collection of AR objects" do
      subject { klass.limit }

      it "should not call ::scoped" do
        subject.should_not_receive(:scoped)
        subject.decorate
      end

      it_should_behave_like "a method that creates a DecoratedEnumerableProxy"
    end

    describe '#decorate - decorate collections of AR objects' do
      let(:klass) { Product }

      it_should_behave_like "a method that decorates a collection of AR objects"
    end

    describe '#decorate - decorate collections of namespaced AR objects' do
      let(:klass) { Namespace::Product }

      it_should_behave_like "a method that decorates a collection of AR objects"
    end
  end
end
