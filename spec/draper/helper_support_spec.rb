require 'spec_helper'

describe Draper::HelperSupport do
  let(:product) { Product.new }

  context '#decorate' do
    it 'renders a block' do
      output = ApplicationController.decorate(product){|p| p.model.object_id }
      output.should == product.object_id
    end
    
    it 'uses #capture so Rails only renders the content once' do
      ApplicationController.decorate(product){|p| p.model.object_id }
      ApplicationController.capture_triggered.should be
    end
    
    context "when decorating with a decorator version other than default" do
      it "uses versioned decorator" do
        output = ApplicationController.decorate(product, :version => :api){|p| p.awesome_title }
        output.should == "Special Awesome Title"
      end
    end
  end

end
