class Post < ApplicationRecord
  # attr_accessible :title, :body

  broadcasts if defined? Turbo
end
