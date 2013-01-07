module Draper
  # @private
  class Security
    def initialize
      @methods = []
    end

    def denies(*methods)
      apply_strategy :denies
      add_methods methods
    end

    def denies_all
      apply_strategy :denies_all
    end

    def allows(*methods)
      apply_strategy :allows
      add_methods methods
    end

    def allow?(method)
      case strategy
      when :allows
        methods.include?(method)
      when :denies
        !methods.include?(method)
      when :denies_all
        false
      when nil
        true
      end
    end

    private

    attr_reader :methods, :strategy

    def apply_strategy(new_strategy)
      raise ArgumentError, "Use only one of 'allows', 'denies', or 'denies_all'." if strategy && strategy != new_strategy
      @strategy = new_strategy
    end

    def add_methods(new_methods)
      raise ArgumentError, "Specify at least one method when using #{strategy}" if new_methods.empty?
      @methods += new_methods.map(&:to_sym)
    end
  end
end
