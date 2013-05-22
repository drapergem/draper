class Category < ActiveRecord::Base
  has_one :item
end