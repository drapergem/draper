require 'rubygems'
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)
require 'bundler/setup' if File.exists?(ENV['BUNDLE_GEMFILE'])
Bundler.require :default

require "benchmark"
require "draper"
require "./performance/models"
require "./performance/decorators"

Benchmark.bm do |bm|
  puts "\n[ Exclusivelly using #method_missing for model delegation ]"
  [ 1_000, 10_000, 100_000 ].each do |i|
    puts "\n[ #{i} ]"
    bm.report("#new                 ") do
      i.times do |n|
        ProductDecorator.decorate(Product.new)
      end
    end

    bm.report("#hello_world         ") do
      i.times do |n|
        ProductDecorator.decorate(Product.new).hello_world
      end
    end

    bm.report("#sample_class_method ") do
      i.times do |n|
        ProductDecorator.decorate(Product.new).class.sample_class_method
      end
    end
  end

  puts "\n[ Defining methods on method_missing first hit ]"
  [ 1_000, 10_000, 100_000 ].each do |i|
    puts "\n[ #{i} ]"
    bm.report("#new                 ") do
      i.times do |n|
        FastProductDecorator.decorate(FastProduct.new)
      end
    end

    bm.report("#hello_world         ") do
      i.times do |n|
        FastProductDecorator.decorate(FastProduct.new).hello_world
      end
    end

    bm.report("#sample_class_method ") do
      i.times do |n|
        FastProductDecorator.decorate(FastProduct.new).class.sample_class_method
      end
    end
  end
end
