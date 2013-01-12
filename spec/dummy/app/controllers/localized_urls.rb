module LocalizedUrls
  def default_url_options(options = {})
    {locale: I18n.locale, host: "www.example.com", port: 12345}
  end
end
