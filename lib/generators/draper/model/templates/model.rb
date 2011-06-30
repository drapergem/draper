class <%= singular_name.camelize %>Decorator < Draper::Base

  # Rails Helpers
  #   Rails helpers like content_tag, link_to, and pluralize are already
  #   available to you. If you need access to other helpers, include them
  #   like this:
  #     include ActionView::Helpers::TextHelper
  #   Or pull in the whole kitchen sink:
  #     include ActionView::Helpers

  # Wrapper Methods
  #   Control access to the wrapped subject's methods using one of the following:
  #
  #   To allow _only_ the listed methods:
  #     allows :method1, :method2
  #
  #   To allow everything _except_ the listed methods:
  #     denies :method1, :method2

  # Presentation Methods
  #   Define presentation-related instance methods. Ex:
  #     def formatted_created_at
  #       content_tag :span, created_at.strftime("%A")
  #     end
end