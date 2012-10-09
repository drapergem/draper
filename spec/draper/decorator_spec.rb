require 'spec_helper'

describe Draper::Decorator do
  before(:each){ ApplicationController.new.view_context }
  subject{ Decorator.new(source) }
  let(:source){ Product.new }
  let(:non_active_model_source){ NonActiveModelProduct.new }

  context("proxying class methods") do
    it "pass missing class method calls on to the wrapped class" do
      subject.class.sample_class_method.should == "sample class method"
    end

    it "respond_to a wrapped class method" do
      subject.class.should respond_to(:sample_class_method)
    end

    it "still respond_to its own class methods" do
      subject.class.should respond_to(:own_class_method)
    end
  end

  context(".helpers") do
    it "have a valid view_context" do
      subject.helpers.should be
    end

    it "is aliased to .h" do
      subject.h.should == subject.helpers
    end
  end

  context("#helpers") do
    it "have a valid view_context" do
      Decorator.helpers.should be
    end

    it "is aliased to #h" do
      Decorator.h.should == Decorator.helpers
    end
  end

  context(".decorates") do
    it "sets the model class for the decorator" do
      ProductDecorator.new(source).model_class.should == Product
    end

    it "returns decorator if it's decorated model already" do
      product_decorator = ProductDecorator.new(source)
      ProductDecorator.new(product_decorator).model.should be_instance_of Product
    end

    it "handle plural-like words properly'" do
      class Business; end
      expect do
        class BusinessDecorator < Draper::Decorator
          decorates:business
        end
        BusinessDecorator.model_class.should == Business
      end.to_not raise_error
    end

    context("accepts ActiveRecord like :class_name option too") do
      it "accepts constants for :class" do
        expect do
        class CustomDecorator < Draper::Decorator
          decorates :product, :class => Product
        end
        CustomDecorator.model_class.should == Product
        end.to_not raise_error
      end

      it "accepts constants for :class_name" do
        expect do
        class CustomDecorator < Draper::Decorator
          decorates :product, :class_name => Product
        end
        CustomDecorator.model_class.should == Product
        end.to_not raise_error
      end

      it "accepts strings for :class" do
        expect do
        class CustomDecorator < Draper::Decorator
          decorates :product, :class => 'Product'
        end
        CustomDecorator.model_class.should == Product
        end.to_not raise_error
      end

      it "accepts strings for :class_name" do
        expect do
        class CustomDecorator < Draper::Decorator
          decorates :product, :class_name => 'Product'
        end
        CustomDecorator.model_class.should == Product
        end.to_not raise_error
      end
    end

    it "creates a named accessor for the wrapped model" do
      pd = ProductDecorator.new(source)
      pd.send(:product).should == source
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

  context(".decorates_association") do
    context "for ActiveModel collection associations" do
      before(:each){ subject.class_eval{ decorates_association :similar_products } }
      it "causes the association's method to return a collection of wrapped objects" do
        subject.similar_products.each{ |decorated| decorated.should be_instance_of(ProductDecorator) }
      end
    end

    context "for Plain Old Ruby Object collection associations" do
      before(:each){ subject.class_eval{ decorates_association :poro_similar_products } }
      it "causes the association's method to return a collection of wrapped objects" do
        subject.poro_similar_products.each{ |decorated| decorated.should be_instance_of(ProductDecorator) }
      end
    end

    context "for an ActiveModel singular association" do
      before(:each){ subject.class_eval{ decorates_association :previous_version } }
      it "causes the association's method to return a single wrapped object if the association is singular" do
        subject.previous_version.should be_instance_of(ProductDecorator)
      end
    end

    context "for a Plain Old Ruby Object singular association" do
      before(:each){ subject.class_eval{ decorates_association :poro_previous_version } }
      it "causes the association's method to return a single wrapped object" do
        subject.poro_previous_version.should be_instance_of(ProductDecorator)
      end
    end

    context "with a specific decorator specified" do
      before(:each){ subject.class_eval{ decorates_association :previous_version, :with => SpecificProductDecorator } }
      it "causes the association to be decorated with the specified association" do
        subject.previous_version.should be_instance_of(SpecificProductDecorator)
      end
    end

    context "with a scope specified" do
      before(:each){ subject.class_eval{ decorates_association :thing, :scope => :foo } }
      it "applies the scope before decoration" do
        SomeThing.any_instance.should_receive(:foo).and_return(:bar)
        subject.thing.model.should == :bar
      end
    end

    context "for a polymorphic association" do
      before(:each){ subject.class_eval{ decorates_association :thing, :polymorphic => true } }
      it "causes the association to be decorated with the right decorator" do
        subject.thing.should be_instance_of(SomeThingDecorator)
      end
    end

    context "when the association is nil" do
      before(:each) do
        subject.class_eval{ decorates_association :previous_version }
        source.stub(:previous_version){ nil }
      end
      it "causes the association's method to return nil" do
        subject.previous_version.should be_nil
      end
    end

    context "#find" do
      before(:each){ subject.class_eval{ decorates_association :similar_products } }
      context "with a block" do
        it "delegates to #each" do
          subject.similar_products.source.should_receive :find
          subject.similar_products.find {|p| p.title == "title" }
        end
      end

      context "without a block" do
        it "calls a finder method" do
          subject.similar_products.source.should_not_receive :find
          subject.similar_products.find 1
        end
      end
    end
  end

  context('.decorates_associations') do
    subject { Decorator }
    it "decorates each of the associations" do
      subject.should_receive(:decorates_association).with(:similar_products, {})
      subject.should_receive(:decorates_association).with(:previous_version, {})

      subject.decorates_associations :similar_products, :previous_version
    end

    it "dispatches options" do
      subject.should_receive(:decorates_association).with(:similar_products, :with => ProductDecorator)
      subject.should_receive(:decorates_association).with(:previous_version, :with => ProductDecorator)

      subject.decorates_associations :similar_products, :previous_version, :with => ProductDecorator
    end
  end

  context(".wrapped_object") do
    it "return the wrapped object" do
      subject.wrapped_object.should == source
    end
  end

  context(".source / .to_source") do
    it "return the wrapped object" do
      subject.to_source == source
      subject.source == source
    end
  end

  describe "method selection" do
    it "echos the methods of the wrapped class except default exclusions" do
      source.methods.each do |method|
        unless Draper::Decorator::DEFAULT_DENIED.include?(method)
          subject.should respond_to(method.to_sym)
        end
      end
    end

    it "not override a defined method with a source method" do
      DecoratorWithApplicationHelper.new(source).length.should == "overridden"
    end

    it "not copy the .class, .inspect, or other existing methods" do
      source.class.should_not == subject.class
      source.inspect.should_not == subject.inspect
      source.to_s.should_not == subject.to_s
    end

    context "when an ActiveModel descendant" do
      it "always proxy to_param if it is not defined on the decorator itself" do
        source.stub(:to_param).and_return(1)
        Draper::Decorator.new(source).to_param.should == 1
      end

      it "always proxy id if it is not defined on the decorator itself" do
        source.stub(:id).and_return(123456789)
        Draper::Decorator.new(source).id.should == 123456789
      end

      it "always proxy errors if it is not defined on the decorator itself" do
        Draper::Decorator.new(source).errors.should be_an_instance_of ActiveModel::Errors
      end

      it "never proxy to_param if it is defined on the decorator itself" do
        source.stub(:to_param).and_return(1)
        DecoratorWithSpecialMethods.new(source).to_param.should == "foo"
      end

      it "never proxy id if it is defined on the decorator itself" do
        source.stub(:id).and_return(123456789)
        DecoratorWithSpecialMethods.new(source).id.should == 1337
      end

      it "never proxy errors if it is defined on the decorator itself" do
        DecoratorWithSpecialMethods.new(source).errors.should be_an_instance_of Array
      end
    end
  end

  context 'the decorated model' do
    it 'receives the mixin' do
      source.class.ancestors.include?(Draper::Decoratable)
    end

    it 'includes ActiveModel support' do
      source.class.ancestors.include?(Draper::ActiveModelSupport)
    end
  end

  it "wrap source methods so they still accept blocks" do
    subject.block{"marker"}.should == "marker"
  end

  context ".find" do
    it "lookup the associated model when passed an integer" do
      pd = ProductDecorator.find(1)
      pd.should be_instance_of(ProductDecorator)
      pd.model.should be_instance_of(Product)
    end

    it "lookup the associated model when passed a string" do
      pd = ProductDecorator.find("1")
      pd.should be_instance_of(ProductDecorator)
      pd.model.should be_instance_of(Product)
    end

    it "accept and store a context" do
      pd = ProductDecorator.find(1, :context => :admin)
      pd.context.should == :admin
    end
  end

  context ".find_by_(x)" do
    it "runs the similarly named finder" do
      Product.should_receive(:find_by_name)
      ProductDecorator.find_by_name("apples")
    end

    it "returns a decorated result" do
      ProductDecorator.find_by_name("apples").should be_kind_of(ProductDecorator)
    end

    it "runs complex finders" do
      Product.should_receive(:find_by_name_and_size)
      ProductDecorator.find_by_name_and_size("apples", "large")
    end

    it "runs find_all_by_(x) finders" do
      Product.should_receive(:find_all_by_name_and_size)
      ProductDecorator.find_all_by_name_and_size("apples", "large")
    end

    it "runs find_last_by_(x) finders" do
      Product.should_receive(:find_last_by_name_and_size)
      ProductDecorator.find_last_by_name_and_size("apples", "large")
    end

    it "runs find_or_initialize_by_(x) finders" do
      Product.should_receive(:find_or_initialize_by_name_and_size)
      ProductDecorator.find_or_initialize_by_name_and_size("apples", "large")
    end

    it "runs find_or_create_by_(x) finders" do
      Product.should_receive(:find_or_create_by_name_and_size)
      ProductDecorator.find_or_create_by_name_and_size("apples", "large")
    end

    it "accepts an options hash" do
      Product.should_receive(:find_by_name_and_size).with("apples", "large", {:role => :admin})
      ProductDecorator.find_by_name_and_size("apples", "large", {:role => :admin})
    end

    it "uses the options hash in the decorator instantiation" do
      Product.should_receive(:find_by_name_and_size).with("apples", "large", {:role => :admin})
      pd = ProductDecorator.find_by_name_and_size("apples", "large", {:role => :admin})
      pd.context[:role].should == :admin
    end
  end

  context ".decorate" do
    context "without any context" do
      subject { Draper::Decorator.decorate(source) }

      context "when given a collection of source objects" do
        let(:source) { [Product.new, Product.new] }

        its(:size) { should == source.size }

        it "returns a collection of wrapped objects" do
          subject.each{ |decorated| decorated.should be_instance_of(Draper::Decorator) }
        end

        it 'should accepted and store a context for a collection' do
          subject.context = :admin
          subject.each { |decorated| decorated.context.should == :admin }
        end
      end

      context "when given a struct" do
        # Struct objects implement #each
        let(:source) { Struct.new(:title).new("Godzilla") }

        it "returns a wrapped object" do
          subject.should be_instance_of(Draper::Decorator)
        end
      end

      context "when given a collection of sequel models" do
        # Sequel models implement #each
        let(:source) { [SequelProduct.new, SequelProduct.new] }

        it "returns a collection of wrapped objects" do
          subject.each{ |decorated| decorated.should be_instance_of(Draper::Decorator) }
        end
      end

      context "when given a single source object" do
        let(:source) { Product.new }

        it { should be_instance_of(Draper::Decorator) }

        context "when the input is already decorated" do
          it "does not perform double-decoration" do
            decorated = ProductDecorator.decorate(source)
            ProductDecorator.decorate(decorated).object_id.should == decorated.object_id
          end

          it "overwrites options with provided options" do
            first_run = ProductDecorator.decorate(source, :context => {:role => :user})
            second_run = ProductDecorator.decorate(first_run, :context => {:role => :admin})
            second_run.context[:role].should == :admin
          end

          it "leaves existing options if none are supplied" do
            first_run = ProductDecorator.decorate(source, :context => {:role => :user})
            second_run = ProductDecorator.decorate(first_run)
            second_run.context[:role].should == :user
          end
        end
      end
    end

    context "with a context" do
      let(:context) {{ :some => 'data' }}

      subject { Draper::Decorator.decorate(source, :context => context) }

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

    context "with options" do
      let(:options) {{ :more => "settings" }}

      subject { Draper::Decorator.decorate(source, options ) }

      its(:options) { should eq(options) }
    end

    context "does not infer collections by default" do
      subject { Draper::Decorator.decorate(source).to_ary }

      let(:source) { [Product.new, Widget.new] }

      it "returns a collection of wrapped objects all with the same decorator" do
        subject.first.class.name.should eql 'Draper::Decorator'
        subject.last.class.name.should eql  'Draper::Decorator'
      end
    end

    context "does not infer single items by default" do
      subject { Draper::Decorator.decorate(source) }

      let(:source) { Product.new }

      it "returns a decorator of the type explicity used in the call" do
        subject.class.should eql Draper::Decorator
      end
    end

    context "returns a collection containing only the explicit decorator used in the call" do
      subject { Draper::Decorator.decorate(source, :infer => true).to_ary }

      let(:source) { [Product.new, Widget.new] }

      it "returns a mixed collection of wrapped objects" do
        subject.first.class.should eql ProductDecorator
        subject.last.class.should eql WidgetDecorator
      end
    end

    context "when given a single object" do
      subject { Draper::Decorator.decorate(source, :infer => true) }

      let(:source) { Product.new }

      it "can also infer its decorator" do
        subject.class.should eql ProductDecorator
      end
    end
  end

  context('.==') do
    it "compare the decorated models" do
      other = Draper::Decorator.new(source)
      subject.should == other
    end
  end

  context ".respond_to?" do
    # respond_to? is called by some proxies (id, to_param, errors).
    # This is, why I stub it this way.
    it "delegate respond_to? to the decorated model" do
      other = Draper::Decorator.new(source)
      source.stub(:respond_to?).and_return(false)
      source.stub(:respond_to?).with(:whatever, true).once.and_return("mocked")
      subject.respond_to?(:whatever, true).should == "mocked"
    end
  end

  context 'position accessors' do
    [:first, :last].each do |method|
      context "##{method}" do
        it "return a decorated instance" do
          ProductDecorator.send(method).should be_instance_of ProductDecorator
        end

        it "return the #{method} instance of the wrapped class" do
          ProductDecorator.send(method).model.should == Product.send(method)
        end

        it "accept an optional context" do
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

    it "proxy all calls to decorated collection" do
      paged_array.page_number.should == "magic_value"
      subject.page_number.should == "magic_value"
    end

    it "support Rails partial lookup for a collection" do
      # to support Rails render @collection the returned collection
      # (or its proxy) should implement #to_ary.
      subject.respond_to?(:to_ary).should be true
      subject.to_ary.first.should == ProductDecorator.decorate(paged_array.first)
    end

    it "delegate respond_to? to the wrapped collection" do
      decorator = ProductDecorator.decorate(paged_array)
      paged_array.should_receive(:respond_to?).with(:whatever, true)
      decorator.respond_to?(:whatever, true)
    end

    it "return blank for a decorated empty collection" do
      # This tests that respond_to? is defined for the CollectionDecorator
      # since activesupport calls respond_to?(:empty) in #blank
      decorator = ProductDecorator.decorate(empty_collection)
      decorator.should be_blank
    end

    it "return whether the member is in the array for a decorated wrapped collection" do
      # This tests that include? is defined for the CollectionDecorator
      member = paged_array.first
      subject.respond_to?(:include?)
      subject.include?(member).should == true
      subject.include?(subject.first).should == true
      subject.include?(Product.new).should == false
    end

    it "equal each other when decorating the same collection" do
      subject_one = ProductDecorator.decorate(paged_array)
      subject_two = ProductDecorator.decorate(paged_array)
      subject_one.should == subject_two
    end

    it "not equal each other when decorating different collections" do
      subject_one = ProductDecorator.decorate(paged_array)
      new_paged_array = paged_array + [Product.new]
      subject_two = ProductDecorator.decorate(new_paged_array)
      subject_one.should_not == subject_two
    end

    it "allow decorated access by index" do
      subject = ProductDecorator.decorate(paged_array)
      subject[0].should be_instance_of ProductDecorator
    end

    context "pretends to be of kind of wrapped collection class" do
      subject { ProductDecorator.decorate(paged_array) }

      it "#kind_of? CollectionDecorator" do
        subject.should be_kind_of Draper::CollectionDecorator
      end

      it "#is_a? CollectionDecorator" do
        subject.is_a?(Draper::CollectionDecorator).should be_true
      end

      it "#kind_of? Array" do
        subject.should be_kind_of Array
      end

      it "#is_a? Array" do
        subject.is_a?(Array).should be_true
      end
    end

    context '#all' do
      it "return a decorated collection" do
        ProductDecorator.all.first.should be_instance_of ProductDecorator
      end

      it "accept a context" do
        collection = ProductDecorator.all(:context => :admin)
        collection.first.context.should == :admin
      end
    end

    context(".source / .to_source") do
      it "return the wrapped object" do
        subject.to_source == source
        subject.source == source
      end
    end
  end

  describe "a sample usage with denies" do
    let(:subject_with_denies){ DecoratorWithDenies.new(source) }

    it "proxy methods not listed in denies" do
      subject_with_denies.should respond_to(:hello_world)
    end

    it "not echo methods specified with denies" do
      subject_with_denies.should_not respond_to(:goodnight_moon)
    end

    it "not clobber other decorators' methods" do
      subject.should respond_to(:hello_world)
    end

    it "not allow method_missing to circumvent a deny" do
      expect{subject_with_denies.title}.to raise_error(NoMethodError)
    end
  end

  describe "a sample usage with allows" do
    let(:subject_with_allows){ DecoratorWithAllows.new(source) }

    let(:subject_with_multiple_allows){ DecoratorWithMultipleAllows.new(source) }

    it "echo the allowed method" do
      subject_with_allows.should respond_to(:goodnight_moon)
    end

    it "echo _only_ the allowed method" do
      subject_with_allows.should_not respond_to(:hello_world)
    end

    it "echo the combined allowed methods" do
      subject_with_multiple_allows.should respond_to(:goodnight_moon)
      subject_with_multiple_allows.should respond_to(:hello_world)
    end

    it "echo _only_ the combined allowed methods" do
      subject_with_multiple_allows.should_not respond_to(:title)
    end
  end

  describe "invalid usages of allows and denies" do
    let(:blank_allows){
      class DecoratorWithInvalidAllows < Draper::Decorator
        allows
      end
    }

    let(:blank_denies){
      class DecoratorWithInvalidDenies < Draper::Decorator
        denies
      end
    }

    let(:using_allows_then_denies){
      class DecoratorWithAllowsAndDenies < Draper::Decorator
        allows :hello_world
        denies :goodnight_moon
      end
    }

    let(:using_denies_then_allows){
      class DecoratorWithDeniesAndAllows < Draper::Decorator
        denies :goodnight_moon
        allows :hello_world
      end
    }

    it "raise an exception for a blank allows" do
      expect {blank_allows}.to raise_error(ArgumentError)
    end

    it "raise an exception for a blank denies" do
      expect {blank_denies}.to raise_error(ArgumentError)
    end

    it "raise an exception for calling allows then denies" do
      expect {using_allows_then_denies}.to raise_error(ArgumentError)
    end

    it "raise an exception for calling denies then allows" do
      expect {using_denies_then_allows}.to raise_error(ArgumentError)
    end
  end

  describe "a sample usage with denies_all" do
    let(:subject_with_denies_all){ DecoratorWithDeniesAll.new(source) }

    [:goodnight_moon, :hello_world, :title].each do |method|
      it "does echo #{method} method" do
        subject_with_denies_all.should_not respond_to(method)
      end
    end

    let(:using_denies_all_then_denies_all) {
      class DecoratorWithDeniesAllAndDeniesAll < Draper::Decorator
        denies_all
        denies_all
      end
    }

    it "allows multple calls to .denies_all" do
      expect { using_denies_all_then_denies_all }.to_not raise_error(ArgumentError)
    end
  end

  describe "invalid usages of denies_all" do
    let(:using_allows_then_denies_all) {
      class DecoratorWithAllowsAndDeniesAll < Draper::Decorator
        allows :hello_world
        denies_all
      end
    }
    let(:using_denies_then_denies_all) {
      class DecoratorWithDeniesAndDeniesAll < Draper::Decorator
        denies :goodnight_moon
        denies_all
      end
    }
    let(:using_denies_all_then_allows) {
      class DecoratorWithDeniesAllAndAllows < Draper::Decorator
        denies_all
        allows :hello_world
      end
    }
    let(:using_denies_all_then_denies) {
      class DecoratorWithDeniesAllAndDenies < Draper::Decorator
        denies_all
        denies :goodnight_moon
      end
    }
    it "raises an exception when calling allows then denies_all" do
      expect {using_allows_then_denies_all}.to raise_error(ArgumentError)
    end

    it "raises an exception when calling denies then denies_all" do
      expect {using_denies_then_denies_all}.to raise_error(ArgumentError)
    end

    it "raises an exception when calling denies_all then allows" do
      expect {using_denies_all_then_allows}.to raise_error(ArgumentError)
    end

    it "raises an exception when calling denies_all then denies" do
      expect {using_denies_all_then_denies}.to raise_error(ArgumentError)
    end
  end

  context "in a Rails application" do
    let(:decorator){ DecoratorWithApplicationHelper.decorate(Object.new) }

    it "have access to ApplicationHelper helpers" do
      decorator.uses_hello_world == "Hello, World!"
    end

    it "is able to use the content_tag helper" do
      decorator.sample_content.to_s.should == "<span>Hello, World!</span>"
    end

    it "is able to use the link_to helper" do
      decorator.sample_link.should == "<a href=\"/World\">Hello</a>"
    end

    it "is able to use the pluralize helper" do
      decorator.sample_truncate.should == "Once..."
    end

    it "is able to use l rather than helpers.l" do
      now = Time.now
      helper_proxy = decorator.helpers.instance_variable_get(:@helpers)
      helper_proxy.should_receive(:localize).with(now, :format => :long)
      decorator.l now, :format => :long
    end

    it "is able to access html_escape, a private method" do
      decorator.sample_html_escaped_text.should == '&lt;script&gt;danger&lt;/script&gt;'
    end
  end

  context "#method_missing" do
    context "with an isolated decorator class" do
      let(:decorator_class) { Class.new(Decorator) }
      subject{ decorator_class.new(source) }

      context "when #hello_world is called again" do
        it "proxies method directly after first hit" do
          subject.methods.should_not include(:hello_world)
          subject.hello_world
          subject.methods.should include(:hello_world)
        end
      end

      context "when #hello_world is called for the first time" do
        it "hits method missing" do
          subject.should_receive(:method_missing)
          subject.hello_world
        end
      end
    end

    context "when the delegated method calls a non-existant method" do
      it 'should not try to delegate to non-existant methods to not confuse Kernel#Array' do
        Array(subject).should be_kind_of(Array)
      end

      it "raises the correct NoMethodError" do
        begin
          subject.some_action
        rescue NoMethodError => e
          e.name.should_not == :some_action
        else
          fail("No exception raised")
        end
      end
    end
  end

  describe "#kind_of?" do
    context "pretends to be of kind of model class" do
      it "#kind_of? decorator class" do
        subject.should be_kind_of subject.class
      end

      it "#is_a? decorator class" do
        subject.is_a?(subject.class).should be_true
      end

      it "#kind_of? source class" do
        subject.should be_kind_of source.class
      end

      it "#is_a? source class" do
        subject.is_a?(source.class).should be_true
      end
    end
  end
end
