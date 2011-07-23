class ApplicationController
  extend ActionView::Helpers
  extend ActionView::Helpers::TagHelper
  extend ActionView::Helpers::UrlHelper
  extend ApplicationHelper

  def self.all_helpers
    self
  end
end