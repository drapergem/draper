class PostsController < ApplicationController
  def show
    @post = PostDecorator.find(params[:id])
  end
end
