require 'turbo/broadcastable' if defined? Turbo::Broadcastable # HACK: looks weird, but works

class Post < ApplicationRecord
  # attr_accessible :title, :body

  broadcasts if defined? Turbo::Broadcastable
end
