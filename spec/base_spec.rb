require 'spec_helper'
require 'draper'

describe Draper::Base do
  subject{ Draper::Base.new(source) }
  let(:source){ "Sample String" }
    
  it "should return the wrapped object when asked for source" do
    subject.source.should == source
  end
  
  it "echos the methods of the wrapped class" do
    source.methods.each do |method|
      subject.should respond_to(method)
    end
  end
  
  it "should not copy the .class, .inspect, or other existing methods" do
    source.class.should_not == subject.class
    source.inspect.should_not == subject.inspect
    source.to_s.should_not == subject.to_s
  end
  
  describe "a sample usage with denies" do
    before(:all) do
      class DecoratorWithDenies < Draper::Base  
        denies :upcase
        
        def sample_content
          content_tag :span, "Hello, World!"
        end
        
        def sample_link
          link_to "Hello", "/World"
        end
        
        def sample_truncate
          ActionView::Helpers::TextHelper.truncate("Once upon a time", :length => 7)
        end
      end
    end
    
    let(:subject_with_denies){ DecoratorWithDenies.new(source) }
    
    it "should not echo methods specified with denies" do
      subject_with_denies.should_not respond_to(:upcase)
    end

    it "should not clobber other decorators' methods" do
      subject.should respond_to(:upcase)
    end    
    
    it "should be able to use the content_tag helper" do
      subject_with_denies.sample_content.to_s.should == "<span>Hello, World!</span>"
    end
    
    it "should be able to use the link_to helper" do
      subject_with_denies.sample_link.should == "<a href=\"/World\">Hello</a>"
    end
    
    it "should be able to use the pluralize helper" do
      pending("Figure out odd interaction when the wrapped source object already has the text_helper methods (ie: a String)")
      subject_with_denies.sample_truncate.should == "Once..."
    end
    
    it "should nullify method_missing to prevent AR from being cute" do
      pending("How to test this without AR? Ugh.")
    end
  end
  
  describe "a sample usage with allows" do
    before(:all) do
      class DecoratorWithAllows < Draper::Base  
        allows :upcase
      end
    end
    
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
      class DecoratorWithInvalidMixing < Draper::Base  
        allows :upcase
        denies :downcase
      end
    }    
    
    let(:using_denies_then_allows){
      class DecoratorWithInvalidMixing < Draper::Base  
        denies :downcase
        allows :upcase        
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
end