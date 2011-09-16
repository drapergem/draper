module ActiveRecord
  class Base
    def method_missing(name, *args)
      name
    end
  end
end
