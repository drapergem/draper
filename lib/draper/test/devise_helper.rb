module Draper
  module DeviseHelper
    def sign_in(resource_or_scope, resource = nil)
      scope = Devise::Mapping.find_scope!(resource_or_scope)
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
