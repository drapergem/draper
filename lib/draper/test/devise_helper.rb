module Draper
  module DeviseHelper
    def sign_in(resource_or_scope, resource = nil)
      scope = begin
        Devise::Mapping.find_scope!(resource_or_scope)
      rescue RuntimeError => e
        # Draper 1.0 didn't require the mapping to exist
        ActiveSupport::Deprecation.warn("#{e.message}.\nUse `sign_in :user, mock_user` instead.", caller)
        :user
      end

      _stub_current_scope scope, resource || resource_or_scope
    end

    def sign_out(resource_or_scope)
      scope = Devise::Mapping.find_scope!(resource_or_scope)
      _stub_current_scope scope, nil
    end

    private

    def _stub_current_scope(scope, resource)
      Draper::ViewContext.current.controller.singleton_class.class_eval do
        define_method "current_#{scope}" do
          resource
        end
      end
    end
  end
end
