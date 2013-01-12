require 'spec_helper'

describe Draper::Decorator do
  before { ApplicationController.new.view_context }
  subject { decorator_class.new(source) }
  let(:decorator_class) { Draper::Decorator }
  let(:source) { Product.new }

  describe "#initialize" do
    describe "options validation" do
      let(:valid_options) { {context: {}} }

      it "does not raise error on valid options" do
        expect { decorator_class.new(source, valid_options) }.to_not raise_error
      end

      it "raises error on invalid options" do
        expect { decorator_class.new(source, valid_options.merge(foo: 'bar')) }.to raise_error(ArgumentError, /Unknown key/)
      end
    end

    it "sets the source" do
      subject.source.should be source
    end

    it "stores context" do
      decorator = decorator_class.new(source, context: {some: 'context'})
      decorator.context.should == {some: 'context'}
    end

    context "when decorating an instance of itself" do
      it "does not redecorate" do
        decorator = ProductDecorator.new(source)
        ProductDecorator.new(decorator).source.should be source
      end

      context "when options are supplied" do
        it "overwrites existing context" do
          decorator = ProductDecorator.new(source, context: {role: :admin})
          ProductDecorator.new(decorator, context: {role: :user}).context.should == {role: :user}
        end
      end

      context "when no options are supplied" do
        it "preserves existing context" do
          decorator = ProductDecorator.new(source, context: {role: :admin})
          ProductDecorator.new(decorator).context.should == {role: :admin}
        end
      end
    end

    it "decorates other decorators" do
      decorator = ProductDecorator.new(source)
      SpecificProductDecorator.new(decorator).source.should be decorator
    end

    it "warns if target is already decorated with the same decorator class" do
      warning_message = nil
      Object.any_instance.stub(:warn) { |message| warning_message = message }

      deep_decorator = SpecificProductDecorator.new(ProductDecorator.new(Product.new))
      expect {
        ProductDecorator.new(deep_decorator)
      }.to change { warning_message }
      warning_message.should =~ /ProductDecorator/
      warning_message.should include caller(1).first
    end
  end

  describe "#context=" do
    it "modifies the context" do
      decorator = decorator_class.new(source, context: {some: 'context'})
      decorator.context = {some: 'other_context'}
      decorator.context.should == {some: 'other_context'}
    end
  end

  describe ".decorate_collection" do
    let(:source) { [Product.new, Widget.new] }

    describe "options validation" do
      let(:valid_options) { {with: :infer, context: {}} }
      before(:each) { Draper::CollectionDecorator.stub(:new) }

      it "does not raise error on valid options" do
        expect { ProductDecorator.decorate_collection(source, valid_options) }.to_not raise_error
      end

      it "raises error on invalid options" do
        expect { ProductDecorator.decorate_collection(source, valid_options.merge(foo: 'bar')) }.to raise_error(ArgumentError, /Unknown key/)
      end
    end

    context "when a custom collection decorator does not exist" do
      subject { WidgetDecorator.decorate_collection(source) }

      it "returns a regular collection decorator" do
        subject.should be_a Draper::CollectionDecorator
        subject.should == source
      end

      it "uses itself as the item decorator by default" do
        subject.each {|item| item.should be_a WidgetDecorator}
      end
    end

    context "when a custom collection decorator exists" do
      subject { ProductDecorator.decorate_collection(source) }

      it "returns the custom collection decorator" do
        subject.should be_a ProductsDecorator
        subject.should == source
      end

      it "uses itself as the item decorator by default" do
        subject.each {|item| item.should be_a ProductDecorator}
      end
    end

    context "with context" do
      subject { ProductDecorator.decorate_collection(source, with: :infer, context: {some: 'context'}) }

      it "passes the context to the collection decorator" do
        subject.context.should == {some: 'context'}
      end
    end
  end

  describe "#helpers" do
    it "returns a HelperProxy" do
      subject.helpers.should be_a Draper::HelperProxy
    end

    it "is aliased to #h" do
      subject.h.should be subject.helpers
    end

    it "initializes the wrapper only once" do
      helper_proxy = subject.helpers
      helper_proxy.stub(:test_method) { "test_method" }
      subject.helpers.test_method.should == "test_method"
      subject.helpers.test_method.should == "test_method"
    end
  end

  describe "#localize" do
    before { subject.helpers.should_receive(:localize).with(:an_object, {some: 'parameter'}) }

    it "delegates to #helpers" do
      subject.localize(:an_object, some: 'parameter')
    end

    it "is aliased to #l" do
      subject.l(:an_object, some: 'parameter')
    end
  end

  describe ".helpers" do
    it "returns a HelperProxy" do
      subject.class.helpers.should be_a Draper::HelperProxy
    end

    it "is aliased to .h" do
      subject.class.h.should be subject.class.helpers
    end
  end

  describe ".decorates" do
    subject { Class.new(Draper::Decorator) }

    context "with a symbol" do
      it "sets .source_class" do
        subject.decorates :product
        subject.source_class.should be Product
      end
    end

    context "with a string" do
      it "sets .source_class" do
        subject.decorates "product"
        subject.source_class.should be Product
      end
    end

    context "with a class" do
      it "sets .source_class" do
        subject.decorates Product
        subject.source_class.should be Product
      end
    end
  end

  describe ".source_class" do
    context "when not set by .decorates" do
      context "for an anonymous decorator" do
        subject { Class.new(Draper::Decorator) }

        it "raises an UninferrableSourceError" do
          expect{subject.source_class}.to raise_error Draper::UninferrableSourceError
        end
      end

      context "for a decorator without a corresponding source" do
        subject { SpecificProductDecorator }

        it "raises an UninferrableSourceError" do
          expect{subject.source_class}.to raise_error Draper::UninferrableSourceError
        end
      end

      context "for a decorator called Decorator" do
        subject { Draper::Decorator }

        it "raises an UninferrableSourceError" do
          expect{subject.source_class}.to raise_error Draper::UninferrableSourceError
        end
      end

      context "for a decorator with a name not ending in Decorator" do
        subject { DecoratorWithApplicationHelper }

        it "raises an UninferrableSourceError" do
          expect{subject.source_class}.to raise_error Draper::UninferrableSourceError
        end
      end

      context "for an inferrable source" do
        subject { ProductDecorator }

        it "infers the source" do
          subject.source_class.should be Product
        end
      end

      context "for a namespaced inferrable source" do
        subject { Namespace::ProductDecorator }

        it "infers the namespaced source" do
          subject.source_class.should be Namespace::Product
        end
      end
    end
  end

  describe ".source_class?" do
    subject { Class.new(Draper::Decorator) }

    it "returns truthy when .source_class is set" do
      subject.stub(:source_class).and_return(Product)
      subject.source_class?.should be_true
    end

    it "returns false when .source_class is not inferrable" do
      subject.stub(:source_class).and_raise(Draper::UninferrableSourceError.new(subject))
      subject.source_class?.should be_false
    end
  end

  describe ".decorates_association" do
    let(:decorator_class) { Class.new(ProductDecorator) }
    before { decorator_class.decorates_association :similar_products, with: ProductDecorator }

    describe "overridden association method" do
      let(:decorated_association) { ->{} }

      describe "options validation" do
        let(:valid_options) { {with: ProductDecorator, scope: :foo, context: {}} }
        before(:each) { Draper::DecoratedAssociation.stub(:new).and_return(decorated_association) }

        it "does not raise error on valid options" do
          expect { decorator_class.decorates_association :similar_products, valid_options }.to_not raise_error
        end

        it "raises error on invalid options" do
          expect { decorator_class.decorates_association :similar_products, valid_options.merge(foo: 'bar') }.to raise_error(ArgumentError, /Unknown key/)
        end
      end

      it "creates a DecoratedAssociation" do
        Draper::DecoratedAssociation.should_receive(:new).with(subject, :similar_products, {with: ProductDecorator}).and_return(decorated_association)
        subject.similar_products
      end

      it "receives the Decorator" do
        Draper::DecoratedAssociation.should_receive(:new).with(kind_of(decorator_class), :similar_products, {with: ProductDecorator}).and_return(decorated_association)
        subject.similar_products
      end

      it "memoizes the DecoratedAssociation" do
        Draper::DecoratedAssociation.should_receive(:new).once.and_return(decorated_association)
        subject.similar_products
        subject.similar_products
      end

      it "calls the DecoratedAssociation" do
        Draper::DecoratedAssociation.stub(:new).and_return(decorated_association)
        decorated_association.should_receive(:call).and_return(:decorated)
        subject.similar_products.should be :decorated
      end
    end
  end

  describe ".decorates_associations" do
    subject { decorator_class }

    it "decorates each of the associations" do
      subject.should_receive(:decorates_association).with(:similar_products, {})
      subject.should_receive(:decorates_association).with(:previous_version, {})

      subject.decorates_associations :similar_products, :previous_version
    end

    it "dispatches options" do
      subject.should_receive(:decorates_association).with(:similar_products, {with: ProductDecorator})
      subject.should_receive(:decorates_association).with(:previous_version, {with: ProductDecorator})

      subject.decorates_associations :similar_products, :previous_version, with: ProductDecorator
    end
  end

  describe "#applied_decorators" do
    it "returns a list of decorators applied to a model" do
      decorator = ProductDecorator.new(SpecificProductDecorator.new(Product.new))
      decorator.applied_decorators.should == [SpecificProductDecorator, ProductDecorator]
    end
  end

  describe "#decorated_with?" do
    it "checks if a decorator has been applied to a model" do
      decorator = ProductDecorator.new(SpecificProductDecorator.new(Product.new))
      decorator.should be_decorated_with ProductDecorator
      decorator.should be_decorated_with SpecificProductDecorator
      decorator.should_not be_decorated_with WidgetDecorator
    end
  end

  describe "#decorated?" do
    it "returns true" do
      subject.should be_decorated
    end
  end

  describe "#source" do
    it "returns the wrapped object" do
      subject.source.should be source
    end

    it "is aliased to #to_source" do
      subject.to_source.should be source
    end

    it "is aliased to #model" do
      subject.model.should be source
    end
  end

  describe "#to_model" do
    it "returns the decorator" do
      subject.to_model.should be subject
    end
  end

  describe "#to_param" do
    it "proxies to the source" do
      source.stub(:to_param).and_return(42)
      subject.to_param.should == 42
    end
  end

  describe "#==" do
    context "with itself" do
      it "returns true" do
        (subject == subject).should be_true
      end
    end

    context "with another decorator having the same source" do
      it "returns true" do
        (subject == ProductDecorator.new(source)).should be_true
      end
    end

    context "with another decorator having a different source" do
      it "returns false" do
        (subject == ProductDecorator.new(Object.new)).should be_false
      end
    end

    context "with the source object" do
      it "returns true" do
        (subject == source).should be_true
      end
    end

    context "with another object" do
      it "returns false" do
        (subject == Object.new).should be_false
      end
    end
  end

  describe "#===" do
    context "with itself" do
      it "returns true" do
        (subject === subject).should be_true
      end
    end

    context "with another decorator having the same source" do
      it "returns true" do
        (subject === ProductDecorator.new(source)).should be_true
      end
    end

    context "with another decorator having a different source" do
      it "returns false" do
        (subject === ProductDecorator.new(Object.new)).should be_false
      end
    end

    context "with the source object" do
      it "returns true" do
        (subject === source).should be_true
      end
    end

    context "with another object" do
      it "returns false" do
        (subject === Object.new).should be_false
      end
    end
  end

  describe "#respond_to?" do
    let(:decorator_class) { Class.new(ProductDecorator) }

    it "returns true for its own methods" do
      subject.should respond_to :awesome_title
    end

    it "returns true for the source's methods" do
      subject.should respond_to :title
    end

    context "with include_private" do
      it "returns true for its own private methods" do
        subject.respond_to?(:awesome_private_title, true).should be_true
      end

      it "returns false for the source's private methods" do
        subject.respond_to?(:private_title, true).should be_false
      end
    end

    context "with method security" do
      it "respects allows" do
        subject.class.allows :hello_world

        subject.should respond_to :hello_world
        subject.should_not respond_to :goodnight_moon
      end

      it "respects denies" do
        subject.class.denies :goodnight_moon

        subject.should respond_to :hello_world
        subject.should_not respond_to :goodnight_moon
      end

      it "respects denies_all" do
        subject.class.denies_all

        subject.should_not respond_to :hello_world
        subject.should_not respond_to :goodnight_moon
      end
    end
  end

  describe ".respond_to?" do
    subject { Class.new(ProductDecorator) }

    context "without a source class" do
      it "returns true for its own class methods" do
        subject.should respond_to :my_class_method
      end

      it "returns false for other class methods" do
        subject.should_not respond_to :sample_class_method
      end
    end

    context "with a source_class" do
      before { subject.decorates :product }

      it "returns true for its own class methods" do
        subject.should respond_to :my_class_method
      end

      it "returns true for the source's class methods" do
        subject.should respond_to :sample_class_method
      end
    end
  end

  describe "proxying" do
    context "instance methods" do
      let(:decorator_class) { Class.new(ProductDecorator) }

      it "does not proxy methods that are defined on the decorator" do
        subject.overridable.should be :overridden
      end

      it "does not proxy methods inherited from Object" do
        subject.inspect.should_not be source.inspect
      end

      it "proxies missing methods that exist on the source" do
        source.stub(:hello_world).and_return(:proxied)
        subject.hello_world.should be :proxied
      end

      it "adds proxied methods to the decorator when they are used" do
        subject.methods.should_not include :hello_world
        subject.hello_world
        subject.methods.should include :hello_world
      end

      it "passes blocks to proxied methods" do
        subject.block{"marker"}.should == "marker"
      end

      it "does not confuse Kernel#Array" do
        Array(subject).should be_a Array
      end

      it "proxies delegated methods" do
        subject.delegated_method.should == "Yay, delegation"
      end

      it "does not proxy private methods" do
        expect{subject.private_title}.to raise_error NoMethodError
      end

      context "with method security" do
        it "respects allows" do
          source.stub(:hello_world, :goodnight_moon).and_return(:proxied)
          subject.class.allows :hello_world

          subject.hello_world.should be :proxied
          expect{subject.goodnight_moon}.to raise_error NameError
        end

        it "respects denies" do
          source.stub(:hello_world, :goodnight_moon).and_return(:proxied)
          subject.class.denies :goodnight_moon

          subject.hello_world.should be :proxied
          expect{subject.goodnight_moon}.to raise_error NameError
        end

        it "respects denies_all" do
          source.stub(:hello_world, :goodnight_moon).and_return(:proxied)
          subject.class.denies_all

          expect{subject.hello_world}.to raise_error NameError
          expect{subject.goodnight_moon}.to raise_error NameError
        end
      end
    end

    context "class methods" do
      subject { Class.new(ProductDecorator) }
      let(:source_class) { Product }
      before { subject.decorates source_class }

      it "does not proxy methods that are defined on the decorator" do
        subject.overridable.should be :overridden
      end

      it "proxies missing methods that exist on the source" do
        source_class.stub(:hello_world).and_return(:proxied)
        subject.hello_world.should be :proxied
      end
    end
  end

  describe "method security" do
    let(:decorator_class) { Draper::Decorator }
    let(:security) { stub }
    before { decorator_class.stub(:security).and_return(security) }

    it "delegates .denies to Draper::Security" do
      security.should_receive(:denies).with(:foo, :bar)
      decorator_class.denies :foo, :bar
    end

    it "delegates .denies_all to Draper::Security" do
      security.should_receive(:denies_all)
      decorator_class.denies_all
    end

    it "delegates .allows to Draper::Security" do
      security.should_receive(:allows).with(:foo, :bar)
      decorator_class.allows :foo, :bar
    end
  end

  describe "security inheritance" do
    let(:superclass_instance) { superclass.new(source) }
    let(:subclass_instance) { subclass.new(source) }
    let(:source) { stub(allowed: 1, denied: 2) }
    let(:superclass) { Class.new(Draper::Decorator) }
    let(:subclass) { Class.new(superclass) }

    it "inherits allows from superclass to subclass" do
      superclass.allows(:allowed)
      subclass_instance.should_not respond_to :denied
    end

    it "inherits denies from superclass to subclass" do
      superclass.denies(:denied)
      subclass_instance.should_not respond_to :denied
    end

    it "inherits denies_all from superclass to subclass" do
      superclass.denies_all
      subclass_instance.should_not respond_to :denied
    end

    it "can add extra allows methods" do
      superclass.allows(:allowed)
      subclass.allows(:denied)
      superclass_instance.should_not respond_to :denied
      subclass_instance.should respond_to :denied
    end

    it "can add extra denies methods" do
      superclass.denies(:denied)
      subclass.denies(:allowed)
      superclass_instance.should respond_to :allowed
      subclass_instance.should_not respond_to :allowed
    end

    it "does not pass allows from subclass to superclass" do
      subclass.allows(:allowed)
      superclass_instance.should respond_to :denied
    end

    it "does not pass denies from subclass to superclass" do
      subclass.denies(:denied)
      superclass_instance.should respond_to :denied
    end

    it "does not pass denies_all from subclass to superclass" do
      subclass.denies_all
      superclass_instance.should respond_to :denied
    end

    it "inherits security strategy" do
      superclass.allows :allowed
      expect{subclass.denies :denied}.to raise_error ArgumentError
    end
  end

  context "in a Rails application" do
    let(:decorator_class) { DecoratorWithApplicationHelper }

    it "has access to ApplicationHelper helpers" do
      subject.uses_hello_world.should == "Hello, World!"
    end

    it "is able to use the content_tag helper" do
      subject.sample_content.to_s.should == "<span>Hello, World!</span>"
    end

    it "is able to use the link_to helper" do
      subject.sample_link.should == %{<a href="/World">Hello</a>}
    end

    it "is able to use the truncate helper" do
      subject.sample_truncate.should == "Once..."
    end

    it "is able to access html_escape, a private method" do
      subject.sample_html_escaped_text.should == '&lt;script&gt;danger&lt;/script&gt;'
    end
  end

  it "pretends to be the source class" do
    subject.kind_of?(source.class).should be_true
    subject.is_a?(source.class).should be_true
  end

  it "is still its own class" do
    subject.kind_of?(subject.class).should be_true
    subject.is_a?(subject.class).should be_true
  end

  describe ".decorates_finders" do
    it "extends the Finders module" do
      ProductDecorator.should be_a_kind_of Draper::Finders
    end
  end

  describe "#serializable_hash" do
    let(:decorator_class) { ProductDecorator }

    it "serializes overridden attributes" do
      subject.serializable_hash[:overridable].should be :overridden
    end
  end

  describe ".method_missing" do
    context "when called on an anonymous decorator" do
      subject { ->{ Class.new(Draper::Decorator).fizzbuzz } }
      it { should raise_error NoMethodError }
    end

    context "when called on an uninferrable decorator" do
      subject { ->{ SpecificProductDecorator.fizzbuzz } }
      it { should raise_error NoMethodError }
    end

    context "when called on an inferrable decorator" do
      context "for a method known to the inferred class" do
        subject { ->{ ProductDecorator.model_name } }
        it { should_not raise_error }
      end

      context "for a method unknown to the inferred class" do
        subject { ->{ ProductDecorator.fizzbuzz } }
        it { should raise_error NoMethodError }
      end
    end
  end

end
