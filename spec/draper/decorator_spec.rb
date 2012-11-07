require 'spec_helper'

describe Draper::Decorator do
  before { ApplicationController.new.view_context }
  subject{ Decorator.new(source) }
  let(:source){ Product.new }
  let(:non_active_model_source){ NonActiveModelProduct.new }

  describe "#initialize" do
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

  describe ".decorate" do
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

        it "aliases .new" do
          ProductDecorator.should_receive(:new).with(source, {some: "options"}).and_return(:a_new_decorator)
          ProductDecorator.decorate(source, some: "options").should be :a_new_decorator
        end
      end
    end

    context "with a context" do
      let(:context) { {some: 'data'} }

      subject { Draper::Decorator.decorate(source, context: context) }

      context "when given a collection of source objects" do
        let(:source) { [Product.new, Product.new] }

        it "returns a collection of wrapped objects with the context" do
          subject.each {|decorated| decorated.context.should == context }
        end
      end

      context "when given a single source object" do
        let(:source) { Product.new }

        its(:context) { should == context }
      end
    end

    context "with options" do
      let(:options) { {more: "settings"} }

      subject { Draper::Decorator.decorate(source, options ) }

      its(:options) { should == options }
    end

    context "does not infer collections by default" do
      subject { Draper::Decorator.decorate(source).to_ary }

      let(:source) { [Product.new, Widget.new] }

      it "returns a collection of wrapped objects all with the same decorator" do
        subject.first.should be_an_instance_of Draper::Decorator
        subject.last.should be_an_instance_of Draper::Decorator
      end
    end

    context "does not infer single items by default" do
      subject { Draper::Decorator.decorate(source) }

      let(:source) { Product.new }

      it "returns a decorator of the type explicity used in the call" do
        subject.should be_an_instance_of Draper::Decorator
      end
    end

    context "returns a collection containing only the explicit decorator used in the call" do
      subject { Draper::Decorator.decorate(source, with: :infer) }

      let(:source) { [Product.new, Widget.new] }

      it "returns a mixed collection of wrapped objects" do
        subject.first.should be_an_instance_of ProductDecorator
        subject.last.should be_an_instance_of WidgetDecorator
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

    it "delegates to helpers" do
      subject.localize(:an_object, some: "options")
    end

    it "is aliased to #l" do
      subject.l(:an_object, some: "options")
    end
  end

  describe ".helpers" do
    it "returns a HelperProxy" do
      Decorator.helpers.should be_a Draper::HelperProxy
    end

    it "is aliased to .h" do
      Decorator.h.should be Decorator.helpers
    end
  end

  describe ".decorates_association" do
    context "for ActiveModel collection associations" do
      before { subject.class.decorates_association :similar_products }

      context "when the association is not empty" do
        it "decorates the collection" do
          subject.similar_products.should be_a Draper::CollectionDecorator
          subject.similar_products.each {|item| item.should be_decorated_with ProductDecorator }
        end
      end

      context "when the association is empty" do
        it "doesn't decorate the collection" do
          source.stub(:similar_products).and_return([])
          subject.similar_products.should_not be_a Draper::CollectionDecorator
          subject.similar_products.should be_empty
        end
      end
    end

    context "for Plain Old Ruby Object collection associations" do
      before { subject.class.decorates_association :poro_similar_products }

      context "when the association is not empty" do
        it "decorates the collection" do
          subject.poro_similar_products.should be_a Draper::CollectionDecorator
          subject.poro_similar_products.each {|item| item.should be_decorated_with ProductDecorator }
        end
      end

      context "when the association is empty" do
        it "doesn't decorate the collection" do
          source.stub(:poro_similar_products).and_return([])
          subject.poro_similar_products.should_not be_a Draper::CollectionDecorator
          subject.poro_similar_products.should be_empty
        end
      end
    end

    context "for an ActiveModel singular association" do
      before { subject.class.decorates_association :previous_version }

      context "when the association is present" do
        it "decorates the association" do
          subject.previous_version.should be_decorated_with ProductDecorator
        end
      end

      context "when the association is absent" do
        it "doesn't decorate the association" do
          source.stub(:previous_version).and_return(nil)
          subject.previous_version.should be_nil
        end
      end
    end

    context "for an ActiveModel singular association" do
      before { subject.class.decorates_association :poro_previous_version }

      context "when the association is present" do
        it "decorates the association" do
          subject.poro_previous_version.should be_decorated_with ProductDecorator
        end
      end

      context "when the association is absent" do
        it "doesn't decorate the association" do
          source.stub(:poro_previous_version).and_return(nil)
          subject.poro_previous_version.should be_nil
        end
      end
    end

    context "when a decorator is specified" do
      before { subject.class.decorates_association :previous_version, with: SpecificProductDecorator }

      it "decorates with the specified decorator" do
        subject.previous_version.should be_decorated_with SpecificProductDecorator
      end
    end

    context "with a scope" do
      before { subject.class.decorates_association :thing, scope: :foo }

      it "applies the scope before decoration" do
        SomeThing.any_instance.should_receive(:foo).and_return(:bar)
        subject.thing.model.should == :bar
      end
    end

    context "for a polymorphic association" do
      before { subject.class.decorates_association :thing, polymorphic: true }

      it "makes the association return the right decorator" do
        subject.thing.should be_decorated_with SomeThingDecorator
      end
    end
  end

  describe ".decorates_associations" do
    subject { Decorator }

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

  describe "#decorator" do
    it "returns the decorator itself" do
      subject.decorator.should be subject
    end

    it "is aliased to #decorate" do
      subject.decorate.should be subject
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

  describe "method selection" do
    it "echos the methods of the wrapped class" do
      source.methods.each do |method|
        subject.respond_to?(method.to_sym, true).should be_true
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

  it "wrap source methods so they still accept blocks" do
    subject.block{"marker"}.should == "marker"
  end

  describe "#==" do
    it "compares the decorated models" do
      other = Draper::Decorator.new(source)
      subject.should == other
    end
  end

  describe "#respond_to?" do
    # respond_to? is called by some proxies (id, to_param, errors).
    # This is, why I stub it this way.
    it "delegates to the decorated model" do
      other = Draper::Decorator.new(source)
      source.stub(:respond_to?).and_return(false)
      source.should_receive(:respond_to?).with(:whatever, true).once.and_return("mocked")
      subject.respond_to?(:whatever, true).should == "mocked"
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
    let(:decorator){ DecoratorWithApplicationHelper.decorate(Object.new) }

    it "has access to ApplicationHelper helpers" do
      decorator.uses_hello_world.should == "Hello, World!"
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

    it "is able to access html_escape, a private method" do
      decorator.sample_html_escaped_text.should == '&lt;script&gt;danger&lt;/script&gt;'
    end
  end

  describe "#method_missing" do
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
      it "should not try to delegate to non-existant methods to not confuse Kernel#Array" do
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

  context '#all' do
    it "return a decorated collection" do
      ProductDecorator.all.first.should be_instance_of ProductDecorator
    end

    it "accept a context" do
      collection = ProductDecorator.all(context: :admin)
      collection.first.context.should == :admin
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

    context "with for: symbol" do
      it "sets the finder class" do
        FinderDecorator.has_finders for: :product
        FinderDecorator.finder_class.should be Product
      end
    end

    context "with for: string" do
      it "sets the finder class" do
        FinderDecorator.has_finders for: "some_thing"
        FinderDecorator.finder_class.should be SomeThing
      end
    end

    context "with for: class" do
      it "sets the finder_class" do
        FinderDecorator.has_finders for: Namespace::Product
        FinderDecorator.finder_class.should be Namespace::Product
      end
    end
  end

end
