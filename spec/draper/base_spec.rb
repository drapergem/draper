require 'spec_helper'

describe Draper::Base do
  before(:each){ ApplicationController.new.set_current_view_context }
  subject{ Decorator.new(source) }
  let(:source){ Product.new }

  context("proxying class methods") do
    it "should pass missing class method calls on to the wrapped class" do
      subject.class.sample_class_method.should == "sample class method"
    end

    it "should respond_to a wrapped class method" do
      subject.class.should respond_to(:sample_class_method)
    end

    it "should still respond_to it's own class methods" do
      subject.class.should respond_to(:own_class_method)
    end
  end

  context(".helpers") do
    it "should have a valid view_context" do
      subject.helpers.should be
    end

    it "should be aliased to .h" do
      subject.h.should == subject.helpers
    end
  end

  context("#helpers") do
    it "should have a valid view_context" do
      Decorator.helpers.should be
    end

    it "should be aliased to #h" do
      Decorator.h.should == Decorator.helpers
    end
  end
  
  describe ".initialize_decorator_registration" do
    it "responds to :registered_decorators after initialization" do
      ProductDecorator.decorate(source)
      Product.should respond_to :registered_decorators
    end
  end

  context(".decorates") do
    it "sets the model class for the decorator" do
      ProductDecorator.new(source).model_class.should == Product
    end

    it "should handle plural-like words properly'" do
      class Business; end
      expect do
        class BusinessDecorator < Draper::Base
          decorates:business
        end
        BusinessDecorator.model_class.should == Business
      end.should_not raise_error
    end

    it "creates a named accessor for the wrapped model" do
      pd = ProductDecorator.new(source)
      pd.send(:product).should == source
    end

    context "when using default decorator version" do
      it "sets default version proxy to current decorator" do
        ProductDecorator.decorate(source)
        Product.registered_decorators[:default].should == "ProductDecorator"
      end
    end
    
    context "when using a versioned decorator" do
      it "creates a proxy for versioned decorator in model" do
        Api::ProductDecorator.decorate(:source)
        Product.registered_decorators[:api].should == "Api::ProductDecorator"
      end
    end

    context("namespaced model supporting") do
      let(:source){ Namespace::Product.new }

      it "sets the model class for the decorator" do
        decorator = Namespace::ProductDecorator.new(source)
        decorator.model_class.should == Namespace::Product
      end

      it "creates a named accessor for the wrapped model" do
        pd = Namespace::ProductDecorator.new(source)
        pd.send(:product).should == source
      end
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
          subject.should respond_to(method.to_sym)
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

    it "should always proxy id" do
      source.send :class_eval, "def id; 123456789; end"
      Draper::Base.new(source).id.should == 123456789
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

    it "should accept and store a context" do
      pd = ProductDecorator.find(1, :context => :admin)
      pd.context.should == :admin
    end
  end

  context ".decorate" do
    context "without any context" do
      subject { Draper::Base.decorate(source) }

      context "when given a collection of source objects" do
        let(:source) { [Product.new, Product.new] }

        its(:size) { should == source.size }

        it "returns a collection of wrapped objects" do
          subject.each{ |decorated| decorated.should be_instance_of(Draper::Base) }
        end
      end

      context "when given a single source object" do
        let(:source) { Product.new }

        it { should be_instance_of(Draper::Base) }
      end
    end

    context "with a context" do
      let(:context) {{ :some => 'data' }}

      subject { Draper::Base.decorate(source, :context => context) }

      context "when given a collection of source objects" do
        let(:source) { [Product.new, Product.new] }

        it "returns a collection of wrapped objects with the context" do
          subject.each{ |decorated| decorated.context.should eq(context) }
        end
      end

      context "when given a single source object" do
        let(:source) { Product.new }

        its(:context) { should eq(context) }
      end
    end

    context "does not infer collections by default" do
      subject { Draper::Base.decorate(source).to_ary }

      let(:source) { [Product.new, Widget.new] }

      it "returns a collection of wrapped objects all with the same decorator" do
        subject.first.class.name.should eql 'Draper::Base'
        subject.last.class.name.should eql  'Draper::Base'
      end
    end

    context "does not infer single items by default" do
      subject { Draper::Base.decorate(source) }

      let(:source) { Product.new }

      it "returns a decorator of the type explicity used in the call" do
        subject.class.should eql Draper::Base
      end
    end

    context "returns a collection containing only the explicit decorator used in the call" do
      subject { Draper::Base.decorate(source, :infer => true).to_ary }

      let(:source) { [Product.new, Widget.new] }

      it "returns a mixed collection of wrapped objects" do
        subject.first.class.should eql ProductDecorator
        subject.last.class.should eql WidgetDecorator
      end
    end

    context "when given a single object" do
      subject { Draper::Base.decorate(source, :infer => true) }

      let(:source) { Product.new }

      it "can also infer its decorator" do
        subject.class.should eql ProductDecorator
      end
    end
  end

  context('.==') do
    it "should compare the decorated models" do
      other = Draper::Base.new(source)
      subject.should == other
    end
  end

  context 'position accessors' do
    [:first, :last].each do |method|
      context "##{method}" do
        it "should return a decorated instance" do
          ProductDecorator.send(method).should be_instance_of ProductDecorator
        end

        it "should return the #{method} instance of the wrapped class" do
          ProductDecorator.send(method).model.should == Product.send(method)
        end

        it "should accept an optional context" do
          ProductDecorator.send(method, :context => :admin).context.should == :admin
        end
      end
    end
  end

  describe "collection decoration" do

    # Implementation of #decorate that returns an array
    # of decorated objects is insufficient to deal with
    # situations where the original collection has been
    # expanded with the use of modules (as often the case
    # with paginator gems) or is just more complex then
    # an array.
    module Paginator; def page_number; "magic_value"; end; end
    Array.send(:include, Paginator)
    let(:paged_array) { [Product.new, Product.new] }
    let(:empty_collection) { [] }
    subject { ProductDecorator.decorate(paged_array) }

    it "should proxy all calls to decorated collection" do
      paged_array.page_number.should == "magic_value"
      subject.page_number.should == "magic_value"
    end

    it "should support Rails partial lookup for a collection" do
      # to support Rails render @collection the returned collection
      # (or its proxy) should implement #to_ary.
      subject.respond_to?(:to_ary).should be true
      subject.to_ary.first.should == ProductDecorator.decorate(paged_array.first)
    end

    it "should delegate respond_to? to the wrapped collection" do
      decorator = ProductDecorator.decorate(paged_array)
      paged_array.should_receive(:respond_to?).with(:whatever)
      decorator.respond_to?(:whatever)
    end

    it "should return blank for a decorated empty collection" do
      # This tests that respond_to? is defined for the DecoratedEnumerableProxy
      # since activesupport calls respond_to?(:empty) in #blank
      decorator = ProductDecorator.decorate(empty_collection)
      decorator.should be_blank
    end

    it "should return whether the member is in the array for a decorated wrapped collection" do
      # This tests that include? is defined for the DecoratedEnumerableProxy
      member = paged_array.first
      subject.respond_to?(:include?)
      subject.include?(member).should == true
      subject.include?(subject.first).should == true
      subject.include?(Product.new).should == false
    end

    it "should equal each other when decorating the same collection" do
      subject_one = ProductDecorator.decorate(paged_array)
      subject_two = ProductDecorator.decorate(paged_array)
      subject_one.should == subject_two
    end

    it "should not equal each other when decorating different collections" do
      subject_one = ProductDecorator.decorate(paged_array)
      new_paged_array = paged_array + [Product.new]
      subject_two = ProductDecorator.decorate(new_paged_array)
      subject_one.should_not == subject_two
    end

    it "should allow decorated access by index" do
      subject = ProductDecorator.decorate(paged_array)
      subject[0].should be_instance_of ProductDecorator
    end

    context '#all' do
      it "should return a decorated collection" do
        ProductDecorator.all.first.should be_instance_of ProductDecorator
      end

      it "should accept a context" do
        collection = ProductDecorator.all(:context => :admin)
        collection.first.context.should == :admin
      end
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
      subject_with_allows.should respond_to(:goodnight_moon)
    end

    it "should echo _only_ the allowed method" do
      subject_with_allows.should_not respond_to(:hello_world)
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

  describe "decorator in cancan rules" do
    it "should answer yes to kind_of? source class" do
      subject.kind_of?(source.class).should == true
    end
  end
  
  describe "#method_missing" do
    context "when #hello_world is called for the first time" do
      it "hits method missing" do
        subject.should_receive(:method_missing)
        subject.hello_world
      end
    end
    
    context "when #hello_world is called again" do
      before { subject.hello_world }
      it "proxies method directly after first hit" do
        subject.should_not_receive(:method_missing)
        subject.hello_world
      end
    end
  end
end
