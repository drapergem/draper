<%- module_namespacing do -%>
class <%= class_name.pluralize %>Decorator < <%= collection_parent_class_name %>
  delegate_all

  # Define presentation-specific methods here. Helpers are accessed through
  # `helpers` (aka `h`). You can override attributes, for example:
  #
  #   def heading
  #     helpers.content_tag :h3, class: 'collection' do
  #       "#{count} ".html_safe + klass.name.humanize(count: count)
  #     end
  #   end

end
<% end -%>
