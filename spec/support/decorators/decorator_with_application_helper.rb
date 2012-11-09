class DecoratorWithApplicationHelper < Draper::Decorator
  def uses_hello_world
    h.hello_world
  end

  def sample_content
    h.content_tag :span, "Hello, World!"
  end

  def sample_link
    h.link_to "Hello", "/World"
  end

  def sample_truncate
    h.truncate("Once upon a time", :length => 7)
  end

  def length
    "overridden"
  end

  def sample_html_escaped_text
    h.html_escape '<script>danger</script>'
  end
end
