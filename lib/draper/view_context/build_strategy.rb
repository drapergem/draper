module Draper
  module ViewContext
    # @private
    module BuildStrategy
      def self.new(name, &block)
        const_get(name.to_s.camelize).new(&block)
      end

      class Fast
        def initialize(&block)
          @view_context_class = Class.new(ActionView::Base, &block)
        end

        def call
          view_context_class.respond_to?(:empty) ? view_context_class.empty : view_context_class.new
        end

        private

        attr_reader :view_context_class
      end

      class Full
        def initialize(&block)
          @block = block
        end

        def call
          controller.view_context.tap do |context|
            context.singleton_class.class_eval(&block) if block
          end
        end

        private

        attr_reader :block

        def controller
          Draper::ViewContext.controller ||= Draper.default_controller.new
          Draper::ViewContext.controller.tap do |controller|
            controller.request ||= ActionDispatch::TestRequest.create
          end
        end
      end
    end
  end
end
