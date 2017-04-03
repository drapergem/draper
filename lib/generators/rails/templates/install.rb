<%- module_namespacing do -%>
  class ApplicationDecorator < Draper::Decorator
    delegate_all

    # Define global methods here. Helpers are accessed through `helpers` (aka `h`).
    # You can set methods for all decorators. For example:
    #
    #   def percent(amount)
    #     h.number_to_percentage amount, precision: 2
    #   end

  end
<% end -%>
