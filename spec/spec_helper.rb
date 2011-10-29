require 'rubygems'
require 'bundler/setup'
Bundler.require

Dir['./spec/support/**/*.rb'].each {|file| require file }
