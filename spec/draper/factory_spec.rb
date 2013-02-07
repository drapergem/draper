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
      context "when source is nil" do
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

      it "passes the source to the worker" do
        factory = Factory.new
        source = double

        Factory::Worker.should_receive(:new).with(anything(), source).and_return(->(*){})
        factory.decorate(source)
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
        source = double
        options = {foo: "bar"}
        worker = Factory::Worker.new(double, source)
        decorator = ->(*){}
        worker.stub decorator: decorator

        decorator.should_receive(:call).with(source, options).and_return(:decorated)
        expect(worker.call(options)).to be :decorated
      end
    end

    describe "#decorator" do
      context "for a singular source" do
        context "when decorator_class is specified" do
          it "returns the .decorate method from the decorator" do
            decorator_class = Class.new(Decorator)
            worker = Factory::Worker.new(decorator_class, double)

            expect(worker.decorator).to eq decorator_class.method(:decorate)
          end
        end

        context "when decorator_class is unspecified" do
          it "returns the .decorate method from the source's decorator" do
            decorator_class = Class.new(Decorator)
            source = double(decorator_class: decorator_class)
            worker = Factory::Worker.new(nil, source)

            expect(worker.decorator).to eq decorator_class.method(:decorate)
          end
        end
      end

      context "for a collection source" do
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
          context "and the source is decoratable" do
            it "returns the .decorate method from the source's decorator" do
              decorator_class = Class.new(CollectionDecorator)
              source = []
              source.stub decorator_class: decorator_class
              worker = Factory::Worker.new(nil, source)

              expect(worker.decorator).to eq decorator_class.method(:decorate)
            end
          end

          context "and the source is not decoratable" do
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
