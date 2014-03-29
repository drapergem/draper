class Post < ActiveRecord::Base
  # attr_accessible :title, :body
  scope :active, ->{ where('1 = 1') }
end
