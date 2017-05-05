require 'spec_helper'

module Draper
  describe ViewContext do
    describe "#view_context" do
      let(:base) { Class.new { def view_context; :controller_view_context; end } }
      let(:controller) { Class.new(base) { include ViewContext } }

      it "saves the superclass's view context" do
        expect(ViewContext).to receive(:current=).with(:controller_view_context)
        controller.new.view_context
      end

      it "returns the superclass's view context" do
        expect(controller.new.view_context).to be :controller_view_context
      end
    end

    describe ".controller" do
      it "returns the stored controller from RequestStore" do
        allow(RequestStore).to receive_messages store: {current_controller: :stored_controller}

        expect(ViewContext.controller).to be :stored_controller
      end
    end

    describe ".controller=" do
      it "stores a controller in RequestStore" do
        store = {}
        allow(RequestStore).to receive_messages store: store

        ViewContext.controller = :stored_controller
        expect(store[:current_controller]).to be :stored_controller
      end

      it "cleans context when controller changes" do
        store = {
          current_controller: :stored_controller,
          current_view_context: :stored_view_context
        }

        allow(RequestStore).to receive_messages store: store

        ViewContext.controller = :other_stored_controller

        expect(store).to include(current_controller: :other_stored_controller)
        expect(store).not_to include(:current_view_context)
      end

      it "doesn't clean context when controller is the same" do
        store = {
          current_controller: :stored_controller,
          current_view_context: :stored_view_context
        }

        allow(RequestStore).to receive_messages store: store

        ViewContext.controller = :stored_controller

        expect(store).to include(current_controller: :stored_controller)
        expect(store).to include(current_view_context: :stored_view_context)
      end
    end

    describe ".current" do
      it "returns the stored view context from RequestStore" do
        allow(RequestStore).to receive_messages store: {current_view_context: :stored_view_context}

        expect(ViewContext.current).to be :stored_view_context
      end

      context "when no view context is stored" do
        it "builds a view context" do
          allow(RequestStore).to receive_messages store: {}
          allow(ViewContext).to receive_messages build_strategy: ->{ :new_view_context }
          allow(HelperProxy).to receive(:new).with(:new_view_context).and_return(:new_helper_proxy)

          expect(ViewContext.current).to be :new_helper_proxy
        end

        it "stores the built view context" do
          store = {}
          allow(RequestStore).to receive_messages store: store
          allow(ViewContext).to receive_messages build_strategy: ->{ :new_view_context }
          allow(HelperProxy).to receive(:new).with(:new_view_context).and_return(:new_helper_proxy)

          ViewContext.current
          expect(store[:current_view_context]).to be :new_helper_proxy
        end
      end
    end

    describe ".current=" do
      it "stores a helper proxy for the view context in RequestStore" do
        store = {}
        allow(RequestStore).to receive_messages store: store
        allow(HelperProxy).to receive(:new).with(:stored_view_context).and_return(:stored_helper_proxy)

        ViewContext.current = :stored_view_context
        expect(store[:current_view_context]).to be :stored_helper_proxy
      end
    end

    describe ".clear!" do
      it "clears the stored controller and view controller" do
        store = {current_controller: :stored_controller, current_view_context: :stored_view_context}
        allow(RequestStore).to receive_messages store: store

        ViewContext.clear!
        expect(store).not_to have_key :current_controller
        expect(store).not_to have_key :current_view_context
      end
    end

    describe ".build" do
      it "returns a new view context using the build strategy" do
        allow(ViewContext).to receive_messages build_strategy: ->{ :new_view_context }

        expect(ViewContext.build).to be :new_view_context
      end
    end

    describe ".build!" do
      it "returns a helper proxy for the new view context" do
        allow(ViewContext).to receive_messages build_strategy: ->{ :new_view_context }
        allow(HelperProxy).to receive(:new).with(:new_view_context).and_return(:new_helper_proxy)

        expect(ViewContext.build!).to be :new_helper_proxy
      end

      it "stores the helper proxy" do
        store = {}
        allow(RequestStore).to receive_messages store: store
        allow(ViewContext).to receive_messages build_strategy: ->{ :new_view_context }
        allow(HelperProxy).to receive(:new).with(:new_view_context).and_return(:new_helper_proxy)

        ViewContext.build!
        expect(store[:current_view_context]).to be :new_helper_proxy
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
          allow(ViewContext::BuildStrategy::Fast).to receive(:new) { |&block| block.call }

          expect(ViewContext.test_strategy(:fast){:passed}).to be :passed
        end
      end

      context "with :full" do
        it "creates a full strategy" do
          ViewContext.test_strategy :full
          expect(ViewContext.build_strategy).to be_a ViewContext::BuildStrategy::Full
        end

        it "passes a block to the strategy" do
          allow(ViewContext::BuildStrategy::Full).to receive(:new) { |&block| block.call }

          expect(ViewContext.test_strategy(:full){:passed}).to be :passed
        end
      end
    end
  end
end
