module Draper
  module DecoratesAssigned
    # @overload decorates_assigned(*variables, options = {})
    #   Defines a helper method to access decorated instance variables.
    #
    #   @example
    #     # app/controllers/articles_controller.rb
    #     class ArticlesController < ApplicationController
    #       decorates_assigned :article
    #
    #       def show
    #         @article = Article.find(params[:id])
    #       end
    #     end
    #
    #     # app/views/articles/show.html.erb
    #     <%= article.decorated_title %>
    #
    #   @param [Symbols*] variables
    #     names of the instance variables to decorate (without the `@`).
    #   @param [Hash] options
    #   @option options [Decorator, CollectionDecorator] :with (nil)
    #     decorator class to use. If nil, it is inferred from the instance
    #     variable.
    #   @option options [Hash, #call] :context
    #     extra data to be stored in the decorator. If a Proc is given, it will
    #     be passed the controller and should return a new context hash.
    def decorates_assigned(*variables)
      factory = Draper::Factory.new(variables.extract_options!)

      variables.each do |variable|
        undecorated = "@#{variable}"
        decorated = "@decorated_#{variable}"

        define_method variable do
          return instance_variable_get(decorated) if instance_variable_defined?(decorated)
          instance_variable_set decorated, factory.decorate(instance_variable_get(undecorated), context_args: self)
        end

        helper_method variable
      end
    end
  end
end
