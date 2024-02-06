# frozen_string_literal: true

module Draper
  module Compatibility
    # It would look consistent to use decorated objects inside templates broadcasted with
    # Turbo::Broadcastable.
    #
    # This compatibility patch fixes the issue by overriding the original defaults to decorate the
    # object, that's passed to the partial in a local variable.
    module Broadcastable
      private

      def broadcast_rendering_with_defaults(options)
        return super unless decorator_class?

        # Add the decorated current instance into the locals (see original method for details).
        options[:locals] =
          (options[:locals] || {}).reverse_merge!(model_name.element.to_sym => decorate)

        super
      end
    end
  end
end
