require 'spec_helper'
require 'draper'

describe Draper::Base do
  subject{ Draper::Base.new(source) }
  let(:source){ Product.new }    

  context(".lazy_helpers") do
    it "makes Rails helpers available without using the h. proxy" do
      Draper::Base.lazy_helpers
      subject.send(:pluralize, 5, "cat").should == "5 cats"
    end
  end
  
  context(".model_name") do
    it "should return an ActiveModel::Name instance" do
      Draper::Base.model_name.should be_instance_of(ActiveModel::Name)
    end
  end

  context(".decorates") do
    it "sets the model class for the decorator" do
      ProductDecorator.new(source).model_class == Product
    end
  end
  
  context(".model / .to_model") do
    it "should return the wrapped object" do
      subject.to_model.should == source
      subject.model.should == source
    end
  end
    
  context("selecting methods") do
    it "echos the methods of the wrapped class except default exclusions" do
      source.methods.each do |method|
        unless Draper::Base::DEFAULT_DENIED.include?(method)
          subject.should respond_to(method)
        end
      end
    end
    
    it "should not override a defined method with a source method" do
      DecoratorWithApplicationHelper.new(source).length.should == "overridden"
    end
    
    it "should always proxy to_param" do
      source.send :class_eval, "def to_param; 1; end"
      Draper::Base.new(source).to_param.should == 1
    end
    
    it "should not copy the .class, .inspect, or other existing methods" do
      source.class.should_not == subject.class
      source.inspect.should_not == subject.inspect
      source.to_s.should_not == subject.to_s
    end
  end  

  context 'the decorated model' do
    it 'receives the mixin' do
      source.class.ancestors.include?(Draper::ModelSupport)
    end
  end

  it "should wrap source methods so they still accept blocks" do
    subject.block{"marker"}.should == "marker"
  end
  
  context ".find" do
    it "should lookup the associated model when passed an integer" do
      pd = ProductDecorator.find(1)
      pd.should be_instance_of(ProductDecorator)
      pd.model.should be_instance_of(Product)
    end
  
    it "should lookup the associated model when passed a string" do
      pd = ProductDecorator.find("1")
      pd.should be_instance_of(ProductDecorator)
      pd.model.should be_instance_of(Product)
    end
  end
  
  context ".decorate" do
    it "should return a collection of wrapped objects when given a collection of source objects" do
      sources = [Product.new, Product.new]
      output = Draper::Base.decorate(sources)
      output.should respond_to(:each)
      output.size.should == sources.size
      output.each{ |decorated| decorated.should be_instance_of(Draper::Base) }
    end
    
    it "should return a single wrapped object when given a single source object" do
      output = Draper::Base.decorate(source)
      output.should be_instance_of(Draper::Base)
    end
  end
    
  describe "a sample usage with denies" do    
    let(:subject_with_denies){ DecoratorWithDenies.new(source) }
    
    it "should proxy methods not listed in denies" do
      subject_with_denies.should respond_to(:hello_world)
    end
    
    it "should not echo methods specified with denies" do
      subject_with_denies.should_not respond_to(:goodnight_moon)
    end

    it "should not clobber other decorators' methods" do
      subject.should respond_to(:hello_world)
    end    
    
    it "should not allow method_missing to circumvent a deny" do
      expect{subject_with_denies.title}.to raise_error(NoMethodError)
    end    
  end
  
  describe "a sample usage with allows" do
    let(:subject_with_allows){ DecoratorWithAllows.new(source) }
    
    it "should echo the allowed method" do
      subject_with_allows.should respond_to(:upcase)
    end
    
    it "should echo _only_ the allowed method" do
      subject_with_allows.should_not respond_to(:downcase)
    end
  end
  
  describe "invalid usages of allows and denies" do
    let(:blank_allows){
      class DecoratorWithInvalidAllows < Draper::Base  
        allows
      end
    }
    
    let(:blank_denies){
      class DecoratorWithInvalidDenies < Draper::Base  
        denies
      end
    }
    
    let(:using_allows_then_denies){
      class DecoratorWithAllowsAndDenies < Draper::Base  
        allows :hello_world
        denies :goodnight_moon
      end
    }    
    
    let(:using_denies_then_allows){
      class DecoratorWithDeniesAndAllows < Draper::Base  
        denies :goodnight_moon
        allows :hello_world        
      end
    }

    it "should raise an exception for a blank allows" do
      expect {blank_allows}.should raise_error(ArgumentError)
    end
    
    it "should raise an exception for a blank denies" do
      expect {blank_denies}.should raise_error(ArgumentError)
    end
    
    it "should raise an exception for calling allows then denies" do
      expect {using_allows_then_denies}.should raise_error(ArgumentError)
    end
    
    it "should raise an exception for calling denies then allows" do
      expect {using_denies_then_allows}.should raise_error(ArgumentError)
    end
  end
  
  context "in a Rails application" do
    let(:decorator){ DecoratorWithApplicationHelper.decorate(Object.new) }
    
    it "should have access to ApplicationHelper helpers" do
      decorator.uses_hello_world == "Hello, World!"
    end
    
    it "should be able to use the content_tag helper" do
      decorator.sample_content.to_s.should == "<span>Hello, World!</span>"
    end
    
    it "should be able to use the link_to helper" do
      decorator.sample_link.should == "<a href=\"/World\">Hello</a>"
    end
    
    it "should be able to use the pluralize helper" do
      decorator.sample_truncate.should == "Once..."
    end
  end
end