module Draper
  def self.undecorate(object)
    if object.respond_to?(:decorated?) && object.decorated?
      object.object
    else
      object
    end
  end
end
