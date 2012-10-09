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
