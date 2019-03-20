class PostsController < BaseController
  decorates_assigned :post

  def show
    @post = Post.find(params[:id])
  end

  def mail
    post = Post.find(params[:id])
    email = PostMailer.decorated_email(post).deliver
    render html: email.body.to_s.html_safe
  end

  private

  def goodnight_moon
    "Goodnight, moon!"
  end
  helper_method :goodnight_moon
end
