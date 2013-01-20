require 'spec_helper'
require 'support/shared_examples/view_helpers'

module Draper
  describe Decorator do
    it_behaves_like "view helpers", Decorator.new(Model.new)

    describe "#initialize" do
      describe "options validation" do
        it "does not raise error on valid options" do
          valid_options = {context: {}}
          expect{Decorator.new(Model.new, valid_options)}.not_to raise_error
        end

        it "raises error on invalid options" do
          expect{Decorator.new(Model.new, foo: "bar")}.to raise_error ArgumentError, /Unknown key/
        end
      end

      it "sets the source" do
        source = Model.new
        decorator = Decorator.new(source)

        expect(decorator.source).to be source
      end

      it "stores context" do
        context = {some: "context"}
        decorator = Decorator.new(Model.new, context: context)

        expect(decorator.context).to be context
      end

      context "when decorating an instance of itself" do
        it "applies to the source instead" do
          source = Model.new
          decorated = Decorator.new(source)
          redecorated = Decorator.new(decorated)

          expect(redecorated.source).to be source
        end

        context "with context" do
          it "overwrites existing context" do
            decorated = Decorator.new(Model.new, context: {some: "context"})
            new_context = {other: "context"}
            redecorated = Decorator.new(decorated, context: new_context)

            expect(redecorated.context).to be new_context
          end
        end

        context "without context" do
          it "preserves existing context" do
            old_context = {some: "context"}
            decorated = Decorator.new(Model.new, context: old_context)
            redecorated = Decorator.new(decorated)

            expect(redecorated.context).to be old_context
          end
        end
      end

      it "decorates other decorators" do
        decorated = OtherDecorator.new(Model.new)
        redecorated = Decorator.new(decorated)

        expect(redecorated.source).to be decorated
      end

      context "when it has been applied previously" do
        it "warns" do
          decorated = OtherDecorator.new(Decorator.new(Model.new))

          warning_message = nil
          Object.any_instance.stub(:warn) {|message| warning_message = message }

          expect{Decorator.new(decorated)}.to change{warning_message}
          expect(warning_message).to start_with "Reapplying Draper::Decorator"
          expect(warning_message).to include caller(1).first
        end

        it "decorates anyway" do
          decorated = OtherDecorator.new(Decorator.new(Model.new))
          Object.any_instance.stub(:warn)
          redecorated = Decorator.decorate(decorated)

          expect(redecorated.source).to be decorated
        end
      end
    end

    describe "#context=" do
      it "modifies the context" do
        decorator = Decorator.new(Model.new, context: {some: "context"})
        new_context = {other: "context"}

        decorator.context = new_context
        expect(decorator.context).to be new_context
      end
    end

    describe ".decorate_collection" do
      describe "options validation" do
        before { CollectionDecorator.stub(:new) }

        it "does not raise error on valid options" do
          valid_options = {with: OtherDecorator, context: {}}
          expect{Decorator.decorate_collection([], valid_options)}.not_to raise_error
        end

        it "raises error on invalid options" do
          expect{Decorator.decorate_collection([], foo: "bar")}.to raise_error ArgumentError, /Unknown key/
        end
      end

      context "without a custom collection decorator" do
        it "creates a CollectionDecorator using itself for each item" do
          source = [Model.new]

          CollectionDecorator.should_receive(:new).with(source, with: Decorator)
          Decorator.decorate_collection(source)
        end

        it "passes options to the collection decorator" do
          options = {with: OtherDecorator, context: {some: "context"}}

          CollectionDecorator.should_receive(:new).with([], options)
          Decorator.decorate_collection([], options)
        end
      end

      context "with a custom collection decorator" do
        it "creates a custom collection decorator using itself for each item" do
          source = [Model.new]

          ProductsDecorator.should_receive(:new).with(source, with: ProductDecorator)
          ProductDecorator.decorate_collection(source)
        end

        it "passes options to the collection decorator" do
          options = {with: OtherDecorator, context: {some: "context"}}

          ProductsDecorator.should_receive(:new).with([], options)
          ProductDecorator.decorate_collection([], options)
        end
      end
    end

    describe ".decorates" do
      protect_class Decorator

      it "sets .source_class with a symbol" do
        Decorator.decorates :product

        expect(Decorator.source_class).to be Product
      end

      it "sets .source_class with a string" do
        Decorator.decorates "product"

        expect(Decorator.source_class).to be Product
      end

      it "sets .source_class with a class" do
        Decorator.decorates Product

        expect(Decorator.source_class).to be Product
      end
    end

    describe ".source_class" do
      context "when not set by .decorates" do
        it "raises an error for a so-named 'Decorator'" do
          expect{Decorator.source_class}.to raise_error UninferrableSourceError
        end

        it "raises an error for anonymous decorators" do
          expect{Class.new(Decorator).source_class}.to raise_error UninferrableSourceError
        end

        it "raises an error for a decorator without a model" do
          expect{OtherDecorator.source_class}.to raise_error UninferrableSourceError
        end

        it "raises an error for other naming conventions" do
          expect{ProductPresenter.source_class}.to raise_error UninferrableSourceError
        end

        it "infers the source for '<Model>Decorator'" do
          expect(ProductDecorator.source_class).to be Product
        end

        it "infers namespaced sources" do
          expect(Namespaced::ProductDecorator.source_class).to be Namespaced::Product
        end
      end
    end

    describe ".source_class?" do
      it "returns truthy when .source_class is set" do
        Decorator.stub(:source_class).and_return(Model)

        expect(Decorator.source_class?).to be_true
      end

      it "returns false when .source_class is not inferrable" do
        Decorator.stub(:source_class).and_raise(UninferrableSourceError.new(Decorator))

        expect(Decorator.source_class?).to be_false
      end
    end

    describe ".decorates_association" do
      protect_class Decorator

      describe "options validation" do
        before { DecoratedAssociation.stub(:new).and_return(->{}) }

        it "does not raise error on valid options" do
          valid_options = {with: Class, scope: :sorted, context: {}}
          expect{Decorator.decorates_association(:children, valid_options)}.not_to raise_error
        end

        it "raises error on invalid options" do
          expect{Decorator.decorates_association(:children, foo: "bar")}.to raise_error ArgumentError, /Unknown key/
        end
      end

      describe "defines an association method" do
        it "creates a DecoratedAssociation" do
          options = {with: Class.new, scope: :foo, context: {}}
          Decorator.decorates_association :children, options
          decorator = Decorator.new(Model.new)

          DecoratedAssociation.should_receive(:new).with(decorator, :children, options).and_return(->{})
          decorator.children
        end

        it "memoizes the DecoratedAssociation" do
          Decorator.decorates_association :children
          decorator = Decorator.new(Model.new)

          DecoratedAssociation.should_receive(:new).once.and_return(->{})
          decorator.children
          decorator.children
        end

        it "calls the DecoratedAssociation" do
          Decorator.decorates_association :children
          decorator = Decorator.new(Model.new)
          decorated_association = ->{}
          DecoratedAssociation.stub(:new).and_return(decorated_association)

          decorated_association.should_receive(:call).and_return(:decorated)
          expect(decorator.children).to be :decorated
        end
      end
    end

    describe ".decorates_associations" do
      protect_class Decorator

      it "decorates each of the associations" do
        Decorator.should_receive(:decorates_association).with(:friends, {})
        Decorator.should_receive(:decorates_association).with(:enemies, {})
        Decorator.decorates_associations :friends, :enemies
      end

      it "dispatches options" do
        options = {with: Class.new, scope: :foo, context: {}}

        Decorator.should_receive(:decorates_association).with(:friends, options)
        Decorator.should_receive(:decorates_association).with(:enemies, options)
        Decorator.decorates_associations :friends, :enemies, options
      end
    end

    describe "#applied_decorators" do
      it "returns a list of decorators applied to a model" do
        decorator = ProductDecorator.new(OtherDecorator.new(Decorator.new(Model.new)))

        expect(decorator.applied_decorators).to eq [Decorator, OtherDecorator, ProductDecorator]
      end
    end

    describe "#decorated_with?" do
      it "checks if a decorator has been applied to a model" do
        decorator = ProductDecorator.new(Decorator.new(Model.new))

        expect(decorator).to be_decorated_with Decorator
        expect(decorator).to be_decorated_with ProductDecorator
        expect(decorator).not_to be_decorated_with OtherDecorator
      end
    end

    describe "#decorated?" do
      it "returns true" do
        decorator = Decorator.new(Model.new)

        expect(decorator).to be_decorated
      end
    end

    describe "#source" do
      it "returns the wrapped object" do
        source = Model.new
        decorator = Decorator.new(source)

        expect(decorator.source).to be source
        expect(decorator.model).to be source
        expect(decorator.to_source).to be source
      end
    end

    describe "#to_model" do
      it "returns the decorator" do
        decorator = Decorator.new(Model.new)

        expect(decorator.to_model).to be decorator
      end
    end

    describe "#to_param" do
      it "delegates to the source" do
        decorator = Decorator.new(double(to_param: :delegated))

        expect(decorator.to_param).to be :delegated
      end
    end

    describe "#present?" do
      it "delegates to the source" do
        decorator = Decorator.new(double(present?: :delegated))

        expect(decorator.present?).to be :delegated
      end
    end

    describe "#to_partial_path" do
      it "delegates to the source" do
        decorator = Decorator.new(double(to_partial_path: :delegated))

        expect(decorator.to_partial_path).to be :delegated
      end
    end

    describe ".model_name" do
      it "delegates to the source class" do
        Decorator.stub source_class: double(model_name: :delegated)

        expect(Decorator.model_name).to be :delegated
      end
    end

    describe "#==" do
      it "ensures the source has a decoration-aware #==" do
        source = Object.new
        decorator = Decorator.new(source)

        expect(source).not_to be_a_kind_of Draper::Decoratable::Equality
        decorator == :something
        expect(source).to be_a_kind_of Draper::Decoratable::Equality
      end

      it "is true when source #== is true" do
        source = Model.new
        decorator = Decorator.new(source)
        other = double(source: Model.new)

        source.should_receive(:==).with(other).and_return(true)
        expect(decorator == other).to be_true
      end

      it "is false when source #== is false" do
        source = Model.new
        decorator = Decorator.new(source)
        other = double(source: Model.new)

        source.should_receive(:==).with(other).and_return(false)
        expect(decorator == other).to be_false
      end

    end

    describe "#===" do
      it "is true when #== is true" do
        decorator = Decorator.new(Model.new)
        decorator.stub(:==).with(:anything).and_return(true)

        expect(decorator === :anything).to be_true
      end

      it "is false when #== is false" do
        decorator = Decorator.new(Model.new)
        decorator.stub(:==).with(:anything).and_return(false)

        expect(decorator === :anything).to be_false
      end
    end

    describe ".delegate" do
      protect_class Decorator

      it "defaults the :to option to :source" do
        Object.should_receive(:delegate).with(:foo, :bar, to: :source)
        Decorator.delegate :foo, :bar
      end

      it "does not overwrite the :to option if supplied" do
        Object.should_receive(:delegate).with(:foo, :bar, to: :baz)
        Decorator.delegate :foo, :bar, to: :baz
      end
    end

    context "with .delegate_all" do
      protect_class Decorator

      before { Decorator.delegate_all }

      describe "#method_missing" do
        it "delegates missing methods that exist on the source" do
          decorator = Decorator.new(double(hello_world: :delegated))

          expect(decorator.hello_world).to be :delegated
        end

        it "adds delegated methods to the decorator when they are used" do
          decorator = Decorator.new(double(hello_world: :delegated))

          expect(decorator.methods).not_to include :hello_world
          decorator.hello_world
          expect(decorator.methods).to include :hello_world
        end

        it "passes blocks to delegated methods" do
          source = Model.new
          source.stub(:hello_world).and_return{|*args, &block| block.call}
          decorator = Decorator.new(source)

          expect(decorator.hello_world{:yielded}).to be :yielded
        end

        it "does not confuse Kernel#Array" do
          decorator = Decorator.new(Model.new)

          expect(Array(decorator)).to be_an Array
        end

        it "delegates already-delegated methods" do
          source = Class.new{ delegate :bar, to: :foo }.new
          source.stub foo: double(bar: :delegated)
          decorator = Decorator.new(source)

          expect(decorator.bar).to be :delegated
        end

        it "does not delegate private methods" do
          source = Class.new{ private; def hello_world; end }.new
          decorator = Decorator.new(source)

          expect{decorator.hello_world}.to raise_error NoMethodError
        end

        it "does not delegate methods that do not exist on the source" do
          decorator = Decorator.new(Model.new)

          expect(decorator.methods).not_to include :hello_world
          expect{decorator.hello_world}.to raise_error NoMethodError
          expect(decorator.methods).not_to include :hello_world
        end
      end

      context ".method_missing" do
        context "without a source class" do
          it "raises a NoMethodError on missing methods" do
            expect{Decorator.hello_world}.to raise_error NoMethodError
          end
        end

        context "with a source class" do
          it "delegates methods that exist on the source class" do
            source_class = Class.new
            source_class.stub hello_world: :delegated
            Decorator.stub source_class: source_class

            expect(Decorator.hello_world).to be :delegated
          end

          it "does not delegate methods that do not exist on the source class" do
            Decorator.stub source_class: Class.new

            expect{Decorator.hello_world}.to raise_error NoMethodError
          end
        end
      end

      describe "#respond_to?" do
        it "returns true for its own methods" do
          Decorator.class_eval{def hello_world; end}
          decorator = Decorator.new(Model.new)

          expect(decorator).to respond_to :hello_world
        end

        it "returns true for the source's methods" do
          decorator = Decorator.new(double(hello_world: :delegated))

          expect(decorator).to respond_to :hello_world
        end

        context "with include_private" do
          it "returns true for its own private methods" do
            Decorator.class_eval{private; def hello_world; end}
            decorator = Decorator.new(Model.new)

            expect(decorator.respond_to?(:hello_world, true)).to be_true
          end

          it "returns false for the source's private methods" do
            source = Class.new{private; def hello_world; end}.new
            decorator = Decorator.new(source)

            expect(decorator.respond_to?(:hello_world, true)).to be_false
          end
        end
      end

      describe ".respond_to?" do
        context "without a source class" do
          it "returns true for its own class methods" do
            Decorator.class_eval{def self.hello_world; end}

            expect(Decorator).to respond_to :hello_world
          end

          it "returns false for other class methods" do
            expect(Decorator).not_to respond_to :goodnight_moon
          end
        end

        context "with a source class" do
          it "returns true for its own class methods" do
            Decorator.class_eval{def self.hello_world; end}
            Decorator.stub source_class: Class.new

            expect(Decorator).to respond_to :hello_world
          end

          it "returns true for the source's class methods" do
            Decorator.stub source_class: double(hello_world: :delegated)

            expect(Decorator).to respond_to :hello_world
          end
        end
      end
    end

    describe "class spoofing" do
      it "pretends to be a kind of the source class" do
        decorator = Decorator.new(Model.new)

        expect(decorator.kind_of?(Model)).to be_true
        expect(decorator.is_a?(Model)).to be_true
      end

      it "is still a kind of its own class" do
        decorator = Decorator.new(Model.new)

        expect(decorator.kind_of?(Decorator)).to be_true
        expect(decorator.is_a?(Decorator)).to be_true
      end

      it "pretends to be an instance of the source class" do
        decorator = Decorator.new(Model.new)

        expect(decorator.instance_of?(Model)).to be_true
      end

      it "is still an instance of its own class" do
        decorator = Decorator.new(Model.new)

        expect(decorator.instance_of?(Decorator)).to be_true
      end
    end

    describe ".decorates_finders" do
      protect_class Decorator

      it "extends the Finders module" do
        expect(Decorator).not_to be_a_kind_of Finders
        Decorator.decorates_finders
        expect(Decorator).to be_a_kind_of Finders
      end
    end

  end
end
