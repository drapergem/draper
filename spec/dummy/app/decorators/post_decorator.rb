class PostDecorator < Draper::Decorator
  def posted_date
    if created_at.to_date == DateTime.now.utc.to_date
      "Today"
    else
      "Not Today"
    end
  end

  def path_with_model
    h.post_path(source)
  end

  def path_with_id
    h.post_path(id: id)
  end

  def url_with_model
    h.post_url(source)
  end

  def url_with_id
    h.post_url(id: id)
  end

  def link
    h.link_to id.to_s, self
  end
end
