require File.expand_path("../../product", __FILE__)
module Api
  class ProductDecorator < Draper::Base
    decorates :product, :version => :api

    def awesome_title
      "Special Awesome Title"
    end
  end
end