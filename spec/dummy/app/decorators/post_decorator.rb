class PostDecorator < Draper::Decorator
  # don't delegate_all here because it helps to identify things we
  # have to delegate for ActiveModel compatibility

  # need to delegate attribute methods for AM::Serialization
  # need to delegate id and new_record? for AR::Base#== (Rails 3.0 only)
  delegate :id, :created_at, :new_record?

  def posted_date
    if created_at.to_date == DateTime.now.utc.to_date
      "Today"
    else
      "Not Today"
    end
  end

  def path_with_model
    h.post_path(object)
  end

  def path_with_id
    h.post_path(id: id)
  end

  def url_with_model
    h.post_url(object)
  end

  def url_with_id
    h.post_url(id: id)
  end

  def link
    h.link_to id.to_s, self
  end

  def truncated
    h.truncate("Once upon a time in a world far far away", length: 17, separator: ' ')
  end

  def html_escaped
    h.html_escape("<script>danger</script>")
  end

  def hello_world
    h.hello_world
  end

  def goodnight_moon
    h.goodnight_moon
  end

  def updated_at
    :overridden
  end

  def persisted?
    true
  end
end
