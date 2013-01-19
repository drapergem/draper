require 'spec_helper'

module Draper
  describe ViewContext do
    describe "#view_context" do
      let(:base) { Class.new { def view_context; :controller_view_context; end } }
      let(:controller) { Class.new(base) { include ViewContext } }

      it "saves the superclass's view context" do
        controller.new.view_context
        expect(ViewContext.current).to be :controller_view_context
      end

      it "returns the superclass's view context" do
        expect(controller.new.view_context).to be :controller_view_context
      end
    end

    describe ".controller" do
      it "returns the stored controller from RequestStore" do
        RequestStore.stub store: {current_controller: :stored_controller}
        expect(ViewContext.controller).to be :stored_controller
      end
    end

    describe ".controller=" do
      it "stores a controller in RequestStore" do
        store = {}
        RequestStore.stub store: store

        ViewContext.controller = :stored_controller
        expect(store[:current_controller]).to be :stored_controller
      end
    end

    describe ".current" do
      it "returns the stored view context from RequestStore" do
        RequestStore.stub store: {current_view_context: :stored_view_context}
        expect(ViewContext.current).to be :stored_view_context
      end

      it "falls back to building a view context" do
        RequestStore.stub store: {}
        ViewContext.should_receive(:build).and_return(:new_view_context)
        expect(ViewContext.current).to be :new_view_context
      end
    end

    describe ".current=" do
      it "stores a view context in RequestStore" do
        store = {}
        RequestStore.stub store: store

        ViewContext.current = :stored_view_context
        expect(store[:current_view_context]).to be :stored_view_context
      end
    end

    describe ".clear!" do
      it "clears the stored controller and view controller" do
        store = {current_controller: :stored_controller, current_view_context: :stored_view_context}
        RequestStore.stub store: store

        ViewContext.clear!
        expect(store[:current_controller]).to be_nil
        expect(store[:current_view_context]).to be_nil
      end
    end

    describe ".build" do
      it "calls the build strategy" do
        ViewContext.stub build_strategy: ->{ :new_view_context }
        expect(ViewContext.build).to be :new_view_context
      end
    end

    describe ".build_strategy" do
      it "defaults to full" do
        expect(ViewContext.build_strategy).to be_a ViewContext::BuildStrategy::Full
      end

      it "memoizes" do
        expect(ViewContext.build_strategy).to be ViewContext.build_strategy
      end
    end

    describe ".test_strategy" do
      protect_module ViewContext

      context "with :fast" do
        it "creates a fast strategy" do
          ViewContext.test_strategy :fast
          expect(ViewContext.build_strategy).to be_a ViewContext::BuildStrategy::Fast
        end

        it "passes a block to the strategy" do
          ViewContext::BuildStrategy::Fast.stub(:new).and_return{|&block| block.call}

          expect(ViewContext.test_strategy(:fast){:passed}).to be :passed
        end
      end

      context "with :full" do
        it "creates a full strategy" do
          ViewContext.test_strategy :full
          expect(ViewContext.build_strategy).to be_a ViewContext::BuildStrategy::Full
        end

        it "passes a block to the strategy" do
          ViewContext::BuildStrategy::Full.stub(:new).and_return{|&block| block.call}

          expect(ViewContext.test_strategy(:full){:passed}).to be :passed
        end
      end
    end
  end
end
