require 'rubygems'
require 'bundler/setup'
Bundler.require
require './spec/samples/application_helper.rb'
Dir.glob(['./spec/samples/*.rb', './spec/support/*.rb']) do |file| 
  require file
end
