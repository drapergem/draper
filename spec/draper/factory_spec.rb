require 'spec_helper'

module Draper
  describe Factory do

    describe "#initialize" do
      it "accepts valid options" do
        valid_options = {with: Decorator, context: {foo: "bar"}}
        expect{Factory.new(valid_options)}.not_to raise_error
      end

      it "rejects invalid options" do
        expect{Factory.new(foo: "bar")}.to raise_error ArgumentError, /Unknown key/
      end
    end

    describe "#decorate" do
      context "when object is nil" do
        it "returns nil" do
          factory = Factory.new

          expect(factory.decorate(nil)).to be_nil
        end
      end

      it "calls a worker" do
        factory = Factory.new
        worker = ->(*){ :decorated }

        Factory::Worker.should_receive(:new).and_return(worker)
        expect(factory.decorate(double)).to be :decorated
      end

      it "passes the object to the worker" do
        factory = Factory.new
        object = double

        Factory::Worker.should_receive(:new).with(anything(), object).and_return(->(*){})
        factory.decorate(object)
      end

      context "when the :with option was given" do
        it "passes the decorator class to the worker" do
          decorator_class = double
          factory = Factory.new(with: decorator_class)

          Factory::Worker.should_receive(:new).with(decorator_class, anything()).and_return(->(*){})
          factory.decorate(double)
        end
      end

      context "when the :with option was omitted" do
        it "passes nil to the worker" do
          factory = Factory.new

          Factory::Worker.should_receive(:new).with(nil, anything()).and_return(->(*){})
          factory.decorate(double)
        end
      end

      it "passes options to the call" do
        factory = Factory.new
        worker = ->(*){}
        Factory::Worker.stub new: worker
        options = {foo: "bar"}

        worker.should_receive(:call).with(options)
        factory.decorate(double, options)
      end

      context "when the :context option was given" do
        it "sets the passed context" do
          factory = Factory.new(context: {foo: "bar"})
          worker = ->(*){}
          Factory::Worker.stub new: worker

          worker.should_receive(:call).with(baz: "qux", context: {foo: "bar"})
          factory.decorate(double, {baz: "qux"})
        end

        it "is overridden by explicitly-specified context" do
          factory = Factory.new(context: {foo: "bar"})
          worker = ->(*){}
          Factory::Worker.stub new: worker

          worker.should_receive(:call).with(context: {baz: "qux"})
          factory.decorate(double, context: {baz: "qux"})
        end
      end
    end

  end

  describe Factory::Worker do

    describe "#call" do
      it "calls the decorator method" do
        object = double
        options = {foo: "bar"}
        worker = Factory::Worker.new(double, object)
        decorator = ->(*){}
        worker.stub decorator: decorator

        decorator.should_receive(:call).with(object, options).and_return(:decorated)
        expect(worker.call(options)).to be :decorated
      end

      context "when the :context option is callable" do
        it "calls it" do
          worker = Factory::Worker.new(double, double)
          decorator = ->(*){}
          worker.stub decorator: decorator
          context = {foo: "bar"}

          decorator.should_receive(:call).with(anything(), context: context)
          worker.call(context: ->{ context })
        end

        it "receives arguments from the :context_args option" do
          worker = Factory::Worker.new(double, double)
          worker.stub decorator: ->(*){}
          context = ->{}

          context.should_receive(:call).with(:foo, :bar)
          worker.call(context: context, context_args: [:foo, :bar])
        end

        it "wraps non-arrays passed to :context_args" do
          worker = Factory::Worker.new(double, double)
          worker.stub decorator: ->(*){}
          context = ->{}
          hash = {foo: "bar"}

          context.should_receive(:call).with(hash)
          worker.call(context: context, context_args: hash)
        end
      end

      context "when the :context option is not callable" do
        it "doesn't call it" do
          worker = Factory::Worker.new(double, double)
          decorator = ->(*){}
          worker.stub decorator: decorator
          context = {foo: "bar"}

          decorator.should_receive(:call).with(anything(), context: context)
          worker.call(context: context)
        end
      end

      it "does not pass the :context_args option to the decorator" do
        worker = Factory::Worker.new(double, double)
        decorator = ->(*){}
        worker.stub decorator: decorator

        decorator.should_receive(:call).with(anything(), foo: "bar")
        worker.call(foo: "bar", context_args: [])
      end
    end

    describe "#decorator" do
      context "for a singular object" do
        context "when decorator_class is specified" do
          it "returns the .decorate method from the decorator" do
            decorator_class = Class.new(Decorator)
            worker = Factory::Worker.new(decorator_class, double)

            expect(worker.decorator).to eq decorator_class.method(:decorate)
          end
        end

        context "when decorator_class is unspecified" do
          context "and the object is decoratable" do
            it "returns the object's #decorate method" do
              object = double
              options = {foo: "bar"}
              worker = Factory::Worker.new(nil, object)

              object.should_receive(:decorate).with(options).and_return(:decorated)
              expect(worker.decorator.call(object, options)).to be :decorated
            end
          end

          context "and the object is not decoratable" do
            it "raises an error" do
              object = double
              worker = Factory::Worker.new(nil, object)

              expect{worker.decorator}.to raise_error UninferrableDecoratorError
            end
          end
        end

        context "when the object is a struct" do
          it "returns a singular decorator" do
            object = Struct.new(:stuff).new("things")

            decorator_class = Class.new(Decorator)
            worker = Factory::Worker.new(decorator_class, object)

            expect(worker.decorator).to eq decorator_class.method(:decorate)
          end
        end
      end

      context "for a collection object" do
        context "when decorator_class is a CollectionDecorator" do
          it "returns the .decorate method from the collection decorator" do
            decorator_class = Class.new(CollectionDecorator)
            worker = Factory::Worker.new(decorator_class, [])

            expect(worker.decorator).to eq decorator_class.method(:decorate)
          end
        end

        context "when decorator_class is a Decorator" do
          it "returns the .decorate_collection method from the decorator" do
            decorator_class = Class.new(Decorator)
            worker = Factory::Worker.new(decorator_class, [])

            expect(worker.decorator).to eq decorator_class.method(:decorate_collection)
          end
        end

        context "when decorator_class is unspecified" do
          context "and the object is decoratable" do
            it "returns the .decorate_collection method from the object's decorator" do
              object = []
              decorator_class = Class.new(Decorator)
              object.stub decorator_class: decorator_class
              object.stub decorate: nil
              worker = Factory::Worker.new(nil, object)

              decorator_class.should_receive(:decorate_collection).with(object, foo: "bar", with: nil).and_return(:decorated)
              expect(worker.decorator.call(object, foo: "bar")).to be :decorated
            end
          end

          context "and the object is not decoratable" do
            it "returns the .decorate method from CollectionDecorator" do
              worker = Factory::Worker.new(nil, [])

              expect(worker.decorator).to eq CollectionDecorator.method(:decorate)
            end
          end
        end
      end
    end

  end
end
