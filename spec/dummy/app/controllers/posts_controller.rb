class PostsController < ApplicationController
  def show
    @post = Post.find(params[:id]).decorate
  end
end
