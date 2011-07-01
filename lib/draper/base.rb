module Draper
  class Base  
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::UrlHelper
    include ActionView::Helpers::TextHelper
    include ApplicationHelper if defined?(ApplicationHelper)

    require 'active_support/core_ext/class/attribute'
    class_attribute :denied, :allowed
    attr_accessor   :source
    
    DEFAULT_DENIED = Object.new.methods << :method_missing
    self.denied = DEFAULT_DENIED
    
    def self.denies(*input_denied)
      raise ArgumentError, "Specify at least one method (as a symbol) to exclude when using denies" if input_denied.empty?
      raise ArgumentError, "Use either 'allows' or 'denies', but not both." if self.allowed?
      self.denied += input_denied
    end
    
    def self.allows(*input_allows)
      raise ArgumentError, "Specify at least one method (as a symbol) to allow when using allows" if input_allows.empty?
      #raise ArgumentError, "Use either 'allows' or 'denies', but not both." unless (self.denies == DEFAULT_EXCLUSIONS)
      self.allowed = input_allows
    end
    
    def initialize(subject)
      self.source = subject      
      build_methods
    end   
    
  private
    def select_methods
      self.allowed || (source.public_methods - denied)
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