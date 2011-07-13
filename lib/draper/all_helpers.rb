module Draper
  module AllHelpers
    # Provide access to helper methods from outside controllers and views,
    # such as in Presenter objects. Rails provides ActionController::Base.helpers,
    # but this does not include any of our application helpers.
    def all_helpers
      @all_helpers_proxy ||= begin
        # Start with just the rails helpers. This is the same method used
        # by ActionController::Base.helpers
        # proxy = ActionView::Base.new.extend(_helpers)
        proxy = ActionController::Base.helpers

        # url_for depends on _routes method being defined
        proxy.instance_eval do
          def _routes
            Rails.application.routes
          end
        end
     
        # Import all named path methods
        proxy.extend(Rails.application.routes.named_routes.module)

        # Load all our application helpers to extend
        modules_for_helpers([:all]).each do |mod|
          proxy.extend(mod)
        end

        proxy.instance_eval do
          # A hack since this proxy doesn't pick up default_url_options from anywhere
          def url_for(*args)
            if args.last.is_a?(Hash) && !args.last[:only_path]
              args = args.dup
              args << args.pop.merge(host: ActionMailer::Base.default_url_options[:host])
            end
            super(*args)
          end
        end

        proxy
      end
    end
  end
end