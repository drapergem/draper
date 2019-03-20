module Draper
  def self.undecorate(object)
    if object.respond_to?(:decorated?) && object.decorated?
      object.object
    else
      object
    end
  end

  def self.undecorate_chain(object)
    if object.respond_to?(:decorated?) && object.decorated?
      undecorate_chain(object.object)
    else
      object
    end
  end
end
