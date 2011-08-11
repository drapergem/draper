require 'spec_helper'

describe Draper::ModelSupport do
  subject { Product.new }

  describe '#decorator' do
    its(:decorator) { should be_kind_of(ProductDecorator) }
    its(:decorator) { should be(subject.decorator) }
  end
end
