module Sequel
 class Model
   def each
   end
 end
end

class SequelProduct < Sequel::Model
  def some_attribute
    "hello"
  end
end

