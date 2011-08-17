module Draper
  class Base
    require 'active_support/core_ext/class/attribute'
    class_attribute :denied, :allowed, :model_class
    attr_accessor :context, :model

    DEFAULT_DENIED = Object.new.methods << :method_missing
    FORCED_PROXY = [:to_param]
    self.denied = DEFAULT_DENIED

    def initialize(input, context = nil)
      input.inspect
      self.class.model_class = input.class if model_class.nil?
      @model = input
      self.context = context
      build_methods
    end

    def self.find(input)
      self.new(model_class.find(input))
    end

    def self.decorates(input)
      self.model_class = input.to_s.classify.constantize
      model_class.send :include, Draper::ModelSupport
    end

    def self.denies(*input_denied)
      raise ArgumentError, "Specify at least one method (as a symbol) to exclude when using denies" if input_denied.empty?
      raise ArgumentError, "Use either 'allows' or 'denies', but not both." if self.allowed?
      self.denied += input_denied
    end

    def self.allows(*input_allows)
      raise ArgumentError, "Specify at least one method (as a symbol) to allow when using allows" if input_allows.empty?
      raise ArgumentError, "Use either 'allows' or 'denies', but not both." unless (self.denied == DEFAULT_DENIED)
      self.allowed = input_allows
    end

    def self.decorate(input, context = nil)
      input.respond_to?(:each) ? input.map{|i| new(i, context)} : new(input, context)
    end

    def helpers
      @helpers ||= ApplicationController::all_helpers
    end
    alias :h :helpers

    def self.lazy_helpers
      self.send(:include, Draper::LazyHelpers)
    end

    def self.model_name
      ActiveModel::Name.new(model_class)
    end

    def to_model
      @model
    end

  private
    def select_methods
      specified = self.allowed || (model.public_methods.map{|s| s.to_sym} - denied.map{|s| s.to_sym})
      (specified - self.public_methods.map{|s| s.to_sym}) + FORCED_PROXY
    end

    def build_methods
      select_methods.each do |method|
        (class << self; self; end).class_eval do
          define_method method do |*args, &block|
            model.send method, *args, &block
          end
        end
      end
    end
  end
end
