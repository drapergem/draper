class PostDecorator < Draper::Decorator
  decorates :post

  def posted_date
    if created_at.to_date == Date.today
      "Today"
    else
      "Not Today"
    end
  end

  def path_helper_with_model
    {:post_path => h.post_path(self.model)}
  end

  def path_helper_with_model_id
    {:post_path => h.post_path(:id => self.model.id)}
  end

  def url_helper_with_model
    {:post_url => h.post_url(self.model)}
  end

  def url_helper_with_model_id
    {:post_url => h.post_url(:id => self.model.id)}
  end
end
