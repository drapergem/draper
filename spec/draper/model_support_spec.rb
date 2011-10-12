require 'spec_helper'

describe Drapper::ModelSupport do
  subject { Product.new }

  describe '#decorator' do
    its(:decorator) { should be_kind_of(ProductDecorator) }
    its(:decorator) { should be(subject.decorator) }

    it 'should have abillity to pass block' do
      a = Product.new.decorator { |d| d.awesome_title }
      a.should eql "Awesome Title"
    end
  end
end
