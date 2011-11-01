require 'rubygems'
require 'bundler/setup'
Bundler.require

require './spec/support/samples/active_record.rb'
Dir['./spec/support/**/*.rb'].each {|file| require file }
