class <%= singular_name.camelize %>Decorator < Draper::Base

  # Helpers from Rails an Your Application
  #   You can access any helper via a proxy to ApplicationController
  #
  #   Normal Usage: helpers.number_to_currency(2)
  #   Abbreviated : h.number_to_currency(2)
  #   
  #   You can optionally enable "lazy helpers" by including this module:
  #     include Draper::LazyHelpers
  #   Then use the helpers with no prefix:
  #     number_to_currency(2)

  # Wrapper Methods
  #   Control access to the wrapped subject's methods using one of the following:
  #
  #   To allow only the listed methods (whitelist):
  #     allows :method1, :method2
  #
  #   To allow everything except the listed methods (blacklist):
  #     denies :method1, :method2

  # Presentation Methods
  #   Define your own instance methods. Ex:
  #     def formatted_created_at
  #       content_tag :span, created_at.strftime("%A")
  #     end
end