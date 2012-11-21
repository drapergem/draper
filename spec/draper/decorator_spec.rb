require 'spec_helper'

describe Draper::Decorator do
  before { ApplicationController.new.view_context }
  subject { decorator_class.new(source) }
  let(:decorator_class) { Draper::Decorator }
  let(:source) { Product.new }

  describe "#initialize" do
    it "sets the source" do
      subject.source.should be source
    end

    it "stores options" do
      decorator = decorator_class.new(source, some: "options")
      decorator.options.should == {some: "options"}
    end

    context "when decorating an instance of itself" do
      it "does not redecorate" do
        decorator = ProductDecorator.new(source)
        ProductDecorator.new(decorator).source.should be source
      end

      context "when options are supplied" do
        it "overwrites existing options" do
          decorator = ProductDecorator.new(source, role: :admin)
          ProductDecorator.new(decorator, role: :user).options.should == {role: :user}
        end
      end

      context "when no options are supplied" do
        it "preserves existing options" do
          decorator = ProductDecorator.new(source, role: :admin)
          ProductDecorator.new(decorator).options.should == {role: :admin}
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

  describe ".decorate_collection" do
    subject { ProductDecorator.decorate_collection(source) }
    let(:source) { [Product.new, Widget.new] }

    it "returns a collection decorator" do
      subject.should be_a Draper::CollectionDecorator
      subject.source.should be source
    end

    it "uses itself as the item decorator by default" do
      subject.each {|item| item.should be_a ProductDecorator}
    end

    context "when given :with => :infer" do
      subject { ProductDecorator.decorate_collection(source, with: :infer) }

      it "infers the item decorators" do
        subject.first.should be_a ProductDecorator
        subject.last.should be_a WidgetDecorator
      end
    end

    context "with options" do
      subject { ProductDecorator.decorate_collection(source, with: :infer, some: "options") }

      it "passes the options to the collection decorator" do
        subject.options.should == {some: "options"}
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
    before { subject.helpers.should_receive(:localize).with(:an_object, {some: "options"}) }

    it "delegates to #helpers" do
      subject.localize(:an_object, some: "options")
    end

    it "is aliased to #l" do
      subject.l(:an_object, some: "options")
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

  describe ".decorates_association" do
    let(:decorator_class) { Class.new(ProductDecorator) }
    before { decorator_class.decorates_association :similar_products, with: ProductDecorator }

    describe "overridden association method" do
      let(:decorated_association) { ->{} }

      it "creates a DecoratedAssociation" do
        Draper::DecoratedAssociation.should_receive(:new).with(source, :similar_products, {with: ProductDecorator}).and_return(decorated_association)
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

      it "returns true for the source's private methods" do
        subject.respond_to?(:private_title, true).should be_true
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

  describe "method proxying" do
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

  describe "method security" do
    subject(:decorator_class) { Draper::Decorator }
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

  context "in a Rails application" do
    let(:decorator_class) { DecoratorWithApplicationHelper }

    it "has access to ApplicationHelper helpers" do
      subject.uses_hello_world.should == "Hello, World!"
    end

    it "is able to use the content_tag helper" do
      subject.sample_content.to_s.should == "<span>Hello, World!</span>"
    end

    it "is able to use the link_to helper" do
      subject.sample_link.should == "<a href=\"/World\">Hello</a>"
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

  describe ".has_finders" do
    it "extends the Finders module" do
      ProductDecorator.should be_a_kind_of Draper::Finders
    end

    context "with no options" do
      it "infers the finder class" do
        ProductDecorator.finder_class.should be Product
      end

      context "for a namespaced model" do
        it "infers the finder class" do
          Namespace::ProductDecorator.finder_class.should be Namespace::Product
        end
      end
    end

    context "with :for option" do
      subject { Class.new(Draper::Decorator) }

      context "with a symbol" do
        it "sets the finder class" do
          subject.has_finders for: :product
          subject.finder_class.should be Product
        end
      end

      context "with a string" do
        it "sets the finder class" do
          subject.has_finders for: "some_thing"
          subject.finder_class.should be SomeThing
        end
      end

      context "with a class" do
        it "sets the finder_class" do
          subject.has_finders for: Namespace::Product
          subject.finder_class.should be Namespace::Product
        end
      end
    end
  end

  describe "#serializable_hash" do
    let(:decorator_class) { ProductDecorator }

    it "serializes overridden attributes" do
      subject.serializable_hash[:overridable].should be :overridden
    end
  end

end
