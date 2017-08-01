class PublishPostJob < ActiveJob::Base
  queue_as :default

  def perform(post)
    Rails.logger.debug "Publishing post: #{post.id} of type #{post.class}"
  end
end