source "https://rubygems.org"

gemspec

platforms :ruby do
  gem 'sqlite3', '~> 1.3.6'
end

platforms :jruby do
  gem "minitest"
  gem "activerecord-jdbcsqlite3-adapter"
end

gem "rails", "~> 5.0"
gem "mongoid", github: "mongodb/mongoid"
