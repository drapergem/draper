source "https://rubygems.org"

gemspec

platforms :ruby do
  gem "sqlite3"
end

platforms :jruby do
  gem "minitest", ">= 3.0"
  gem "activerecord-jdbcsqlite3-adapter"
end

version = ENV["RAILS_VERSION"] || "3.2"

eval_gemfile File.expand_path("../gemfiles/#{version}.gemfile", __FILE__)
