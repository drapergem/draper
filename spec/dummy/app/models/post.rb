require 'turbo/broadcastable' if defined? Turbo::Broadcastable # HACK: looks weird, but works

class Post < ApplicationRecord
  # attr_accessible :title, :body

  has_many :comments

  broadcasts if defined? Turbo::Broadcastable
end
