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

  describe '#decorate - decorate collections of AR objects' do
    subject { Product.limit }
    its(:decorate) { should be_kind_of(Draper::DecoratedEnumerableProxy) }

    it "should decorate the collection" do
      subject.decorate.size.should == 1
      subject.decorate.to_ary[0].model.should be_a(Product)
    end
  end

  describe '#decorate - decorate collections of namespaced AR objects' do
    subject { Namespace::Product.limit }
    its(:decorate) { should be_kind_of(Draper::DecoratedEnumerableProxy) }

    it "should decorate the collection" do
      subject.decorate.size.should == 1
      subject.decorate.to_ary[0].model.should be_a(Namespace::Product)
    end
  end
end
