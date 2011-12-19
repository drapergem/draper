module Draper::HelperSupport
  def decorate(input, options = {}, &block)
    capture { block.call(input.decorate(options)) }
  end
end