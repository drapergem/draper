class PostsController < ApplicationController
  def show
    fetch_post
  end

  def mail
    fetch_post
    email = PostMailer.decorated_email(@post).deliver
    render text: email.body
  end

  private

  def fetch_post
    @post = Post.find(params[:id]).decorate
  end
end
