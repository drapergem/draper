class <%= singular_name.camelize %>Decorator < RailsDecorators::Base
  # Rails helpers like content_tag, link_to, and pluralize are already
  # available to you. If you need access to other helpers, include them
  # like this:
  #   include ActionView::Helpers::TextHelper
  # Or pull in the whole kitchen sink:
  #   include ActionView::Helpers

  # Then define presentation-related instance methods. Ex:
  #   def formatted_created_at
  #     content_tag :span, created_at.strftime("%A")
  #   end
end