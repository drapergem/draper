require 'spec_helper'

module Draper
  describe DecoratesAssigned do
    let(:controller_class) do
      Class.new do
        extend DecoratesAssigned

        def self.helper_method(method)
          helper_methods << method
        end

        def self.helper_methods
          @helper_methods ||= []
        end
      end
    end

    describe ".decorates_assigned" do
      it "adds helper methods" do
        controller_class.decorates_assigned :article, :author

        expect(controller_class.instance_methods).to include :article
        expect(controller_class.instance_methods).to include :author

        expect(controller_class.helper_methods).to include :article
        expect(controller_class.helper_methods).to include :author
      end

      it "creates a factory" do
        Factory.should_receive(:new).once
        controller_class.decorates_assigned :article, :author
      end

      it "passes options to the factory" do
        options = {foo: "bar"}

        Factory.should_receive(:new).with(options)
        controller_class.decorates_assigned :article, :author, options
      end

      describe "the generated method" do
        it "decorates the instance variable" do
          object = double
          factory = double
          Factory.stub new: factory

          controller_class.decorates_assigned :article
          controller = controller_class.new
          controller.instance_variable_set "@article", object

          factory.should_receive(:decorate).with(object, context_args: controller).and_return(:decorated)
          expect(controller.article).to be :decorated
        end

        it "memoizes" do
          factory = double
          Factory.stub new: factory

          controller_class.decorates_assigned :article
          controller = controller_class.new

          factory.should_receive(:decorate).once
          controller.article
          controller.article
        end
      end
    end

  end
end
