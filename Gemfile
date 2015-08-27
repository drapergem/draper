source "https://rubygems.org"

gemspec

platforms :ruby do
  gem "sqlite3"
end

platforms :jruby do
  gem "minitest", ">= 3.0"
  gem "activerecord-jdbcsqlite3-adapter", ">= 1.3.0.beta2"
end

group :development, :test do
  gem 'guard-rspec', require: false
  gem 'ruby_gntp'
  gem 'colorize'
end

version = ENV["RAILS_VERSION"] || "4.1"

eval_gemfile File.expand_path("../gemfiles/#{version}.gemfile", __FILE__)
