require 'spec_helper'

describe Draper::HelperSupport do
  let(:product){ Product.new }

  context '#decorate' do
    it 'renders a block' do
      output = ApplicationController.decorate(product){|p| p.model.object_id }
      output.should == product.object_id
    end

    it 'uses #capture so Rails only renders the content once' do
      ApplicationController.decorate(product){|p| p.model.object_id }
      ApplicationController.capture_triggered.should be
    end
  end

end
