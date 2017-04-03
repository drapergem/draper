<%- module_namespacing do -%>
  class ApplicationDecorator < Draper::Decorator
    delegate_all

    # Set methods for all decorated objects.
    # Helpers are accessed through `helpers` (aka `h`). For example:
    #
    #   def percent_amount
    #     h.number_to_percentage object.amount, precision: 2
    #   end

  end
<% end -%>
