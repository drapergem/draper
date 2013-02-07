class PostsController < ApplicationController
  decorates_assigned :post

  def show
    @post = Post.find(params[:id])
  end

  def mail
    post = Post.find(params[:id])
    email = PostMailer.decorated_email(post).deliver
    render text: email.body
  end

  private

  def goodnight_moon
    "Goodnight, moon!"
  end
  helper_method :goodnight_moon
end
