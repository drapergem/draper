class Business < ActiveRecord::Base
  def self.find(id)
    return Business.new
  end
  
  def get_to_work
    "Get To Work!"
  end
  
  def stay_at_work
    "Stay At Work!"
  end
  
  def slogan
    "all work and no play, makes jack a dull boy"
  end
  
  def block
    yield
  end
end
