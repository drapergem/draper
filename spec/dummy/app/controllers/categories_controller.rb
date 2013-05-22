class CategoriesController < ApplicationController
  # if you need user context, it easy to pass something like context: current_user
  # but if user is not logged in (current_user returns nil), draper fails to decorate association
  #
  # as workaround, you able not to pass context, if current_user returns nil, like:
  #
  #    @category = CategoryDecorator.new(Category.find(params[:id]), category_decorator_options)
  #
  #    ...
  #
  #    def category_decorator_options
  #      options = {}
  #      options[:context] = current_user if current_user.present?
  #      options
  #    end
  #
  # but it is not convenient way, in my opinion
  def show
    @category = CategoryDecorator.new(Category.find(params[:id]), context: current_user)
  end


  private

  # simulate not logged in case
  def current_user
    nil
  end
end