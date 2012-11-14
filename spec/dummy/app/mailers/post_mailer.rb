class PostMailer < ApplicationMailer
  default from: "from@example.com"
  layout "application"

  def decorated_email(post)
    @post = post.decorate
    mail to: "to@example.com", subject: "A decorated post"
  end
end
