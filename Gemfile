source :rubygems

gemspec

platforms :ruby do
  gem "sqlite3"
end

platforms :jruby do
  gem "minitest", ">= 3.0"
  gem "activerecord-jdbcsqlite3-adapter", "~> 1.2.2.1"
end

case ENV["RAILS_VERSION"]
when "master"
  gem "rails", github: "rails/rails"
when "3.2", nil
  gem "rails", "~> 3.2.0"
when "3.1"
  gem "rails", "~> 3.1.0"
when "3.0"
  gem "rails", "~> 3.0.0"
end
