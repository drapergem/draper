require "./performance/models"
class ProductDecorator < Draper::Decorator

  def awesome_title
    "Awesome Title"
  end

  # Original #method_missing
  def method_missing(method, *args, &block)
    if allow?(method)
      begin
        model.send(method, *args, &block)
      rescue NoMethodError
        super
      end
    else
      super
    end
  end

end

class FastProductDecorator < Draper::Decorator

  def awesome_title
    "Awesome Title"
  end

  # Modified #method_missing
  def method_missing(method, *args, &block)
    if allow?(method)
      begin
        self.class.send :define_method, method do |*args, &block|
          model.send(method, *args, &block)
        end
        self.send(method, *args, &block)
      rescue NoMethodError
        super
      end
    else
      super
    end
  end

end
