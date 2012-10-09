require './spec/support/samples/product'

module Namespace
  class Product < ActiveRecord::Base
    include Draper::Decoratable

    def self.first
      @@first ||= Namespace::Product.new
    end

    def self.last
      @@last ||= Namespace::Product.new
    end

    def self.all
      [Namespace::Product.new, Namespace::Product.new]
    end

    def self.scoped
      [Namespace::Product.new]
    end

    def self.model_name
      "Namespace::Product"
    end

    def self.find(id)
      return Namespace::Product.new
    end

    def self.sample_class_method
      "sample class method"
    end

    def hello_world
      "Hello, World"
    end

    def goodnight_moon
      "Goodnight, Moon"
    end

    def title
      "Sample Title"
    end

    def block
      yield
    end
  end
end
