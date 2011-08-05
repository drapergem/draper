require 'spec_helper'
require 'draper'

describe Draper::Base do
  subject{ Draper::Base.new(source) }
  let(:source){ Business.new }    

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
      BusinessDecorator.new(source).model_class == Business
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

  it "should wrap source methods so they still accept blocks" do
    subject.block{"marker"}.should == "marker"
  end
  
  context ".find" do
    it "should lookup the associated model when passed an integer" do
      pd = BusinessDecorator.find(1)
      pd.should be_instance_of(BusinessDecorator)
      pd.model.should be_instance_of(Business)
    end
  
    it "should lookup the associated model when passed a string" do
      pd = BusinessDecorator.find("1")
      pd.should be_instance_of(BusinessDecorator)
      pd.model.should be_instance_of(Business)
    end
  end
  
  context ".decorate" do
    it "should return a collection of wrapped objects when given a collection of source objects" do
      sources = [Business.new, Business.new]
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
    
end
