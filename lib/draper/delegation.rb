module Draper
  module Delegation
    # @overload delegate(*methods, options = {})
    #   Overrides {http://api.rubyonrails.org/classes/Module.html#method-i-delegate Module.delegate}
    #   to make `:source` the default delegation target.
    #
    #   @return [void]
    def delegate(*methods)
      options = methods.extract_options!
      super *methods, options.reverse_merge(to: :source)
    end
  end
end
