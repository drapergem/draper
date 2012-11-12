class ApplicationController < ActionController::Base
  protect_from_forgery

  def default_url_options(options = {})
    {locale: I18n.locale, host: "www.example.com", port: nil}
  end
end
