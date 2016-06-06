source "https://rubygems.org"

gemspec

platforms :ruby do
  gem "sqlite3"
end

platforms :jruby do
  gem "minitest"
  gem "activerecord-jdbcsqlite3-adapter"
end

gem "rails", "> 5.x"
gem "mongoid", github: "mongodb/mongoid"
gem "minitest-rails", github: "blowmage/minitest-rails"
