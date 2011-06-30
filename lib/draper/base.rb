module Draper
  class Base  
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::UrlHelper
    include ActionView::Helpers::TextHelper

    require 'active_support/core_ext/class/attribute'
    class_attribute :exclusions, :allowed
    attr_accessor   :source
    
    DEFAULT_EXCLUSIONS = Object.new.methods
    self.exclusions = DEFAULT_EXCLUSIONS
    
    def self.excludes(*input_exclusions)
      raise ArgumentError, "Specify at least one method (as a symbol) to exclude when using excludes" if input_exclusions.empty?
      raise ArgumentError, "Use either 'allows' or 'excludes', but not both." if self.allowed?
      self.exclusions += input_exclusions
    end
    
    def self.allows(*input_allows)
      raise ArgumentError, "Specify at least one method (as a symbol) to allow when using allows" if input_allows.empty?
      #raise ArgumentError, "Use either 'allows' or 'excludes', but not both." unless (self.exclusions == DEFAULT_EXCLUSIONS)
      self.allowed = input_allows
    end
    
    def initialize(subject)
      self.source = subject      
      build_methods
    end   
    
  private
    def select_methods
      self.allowed || (source.public_methods - exclusions)
    end

    def build_methods
      select_methods.each do |method|
        (class << self; self; end).class_eval do
          define_method method do |*args|
            source.send method, *args
          end
        end
      end  
    end    
  end
end