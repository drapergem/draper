class DecoratorWithDenies < Draper::Base  
  denies :upcase
  
  def sample_content
    content_tag :span, "Hello, World!"
  end
  
  def sample_link
    link_to "Hello", "/World"
  end
  
  def sample_truncate
    ActionView::Helpers::TextHelper.truncate("Once upon a time", :length => 7)
  end
end
