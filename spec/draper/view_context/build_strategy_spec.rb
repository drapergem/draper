require 'spec_helper'

def fake_view_context
  double("ViewContext")
end

def fake_controller(view_context = fake_view_context)
  double("Controller", view_context: view_context, request: double("Request"))
end

module Draper
  describe ViewContext::BuildStrategy::Full do
    describe "#call" do
      context "when a current controller is set" do
        it "returns the controller's view context" do
          view_context = fake_view_context
          ViewContext.stub controller: fake_controller(view_context)
          strategy = ViewContext::BuildStrategy::Full.new

          expect(strategy.call).to be view_context
        end
      end

      context "when a current controller is not set" do
        it "uses ApplicationController" do
          view_context = fake_view_context
          stub_const "ApplicationController", double(new: fake_controller(view_context))
          strategy = ViewContext::BuildStrategy::Full.new

          expect(strategy.call).to be view_context
        end
      end

      it "adds a request if one is not defined" do
        controller = Class.new(ActionController::Base).new
        ViewContext.stub controller: controller
        strategy = ViewContext::BuildStrategy::Full.new

        expect(controller.request).to be_nil
        strategy.call
        expect(controller.request).to be_an ActionController::TestRequest
        expect(controller.params).to eq({})

        # sanity checks
        expect(controller.view_context.request).to be controller.request
        expect(controller.view_context.params).to be controller.params
      end

      it "adds methods to the view context from the constructor block" do
        ViewContext.stub controller: fake_controller
        strategy = ViewContext::BuildStrategy::Full.new do
          def a_helper_method; end
        end

        expect(strategy.call).to respond_to :a_helper_method
      end

      it "includes modules into the view context from the constructor block" do
        view_context = Object.new
        ViewContext.stub controller: fake_controller(view_context)
        helpers = Module.new do
          def a_helper_method; end
        end
        strategy = ViewContext::BuildStrategy::Full.new do
          include helpers
        end

        expect(strategy.call).to respond_to :a_helper_method
      end
    end
  end

  describe ViewContext::BuildStrategy::Fast do
    describe "#call" do
      it "returns an instance of a subclass of ActionView::Base" do
        strategy = ViewContext::BuildStrategy::Fast.new

        returned = strategy.call

        expect(returned).to be_an ActionView::Base
        expect(returned.class).not_to be ActionView::Base
      end

      it "returns different instances each time" do
        strategy = ViewContext::BuildStrategy::Fast.new

        expect(strategy.call).not_to be strategy.call
      end

      it "returns the same subclass each time" do
        strategy = ViewContext::BuildStrategy::Fast.new

        expect(strategy.call.class).to be strategy.call.class
      end

      it "adds methods to the view context from the constructor block" do
        strategy = ViewContext::BuildStrategy::Fast.new do
          def a_helper_method; end
        end

        expect(strategy.call).to respond_to :a_helper_method
      end

      it "includes modules into the view context from the constructor block" do
        helpers = Module.new do
          def a_helper_method; end
        end
        strategy = ViewContext::BuildStrategy::Fast.new do
          include helpers
        end

        expect(strategy.call).to respond_to :a_helper_method
      end
    end
  end
end
