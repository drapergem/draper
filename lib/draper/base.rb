module Draper
  class Base      
    require 'active_support/core_ext/class/attribute'
    class_attribute :denied, :allowed, :source_class, :model_class
    attr_accessor :model
    
    DEFAULT_DENIED = Object.new.methods
    FORCED_PROXY = [:to_param]
    self.denied = DEFAULT_DENIED

    def initialize(input)
      if input.instance_of?(Fixnum)
        input = model_class.find(Fixnum)
      end
      input.inspect
      self.class.source_class = input.class
      @model = input      
      build_methods
    end
    
    def self.decorates(input)
      self.model_class = input.to_s.classify.constantize
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

    def self.decorate(input)
      input.respond_to?(:each) ? input.map{|i| new(i)} : new(input)
    end
    
    def helpers
      @helpers ||= ApplicationController::all_helpers
    end
    alias :h :helpers
    
    def self.model_name
      ActiveModel::Name.new(source_class)
    end
    
    def to_model
      @model
    end
            
  private  
    def select_methods
      specified = self.allowed || (model.public_methods - denied)
      (specified - self.public_methods) + FORCED_PROXY
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