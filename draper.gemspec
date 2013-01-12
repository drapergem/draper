# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "draper/version"

Gem::Specification.new do |s|
  s.name        = "draper"
  s.version     = Draper::VERSION
  s.authors     = ["Jeff Casimir", "Steve Klabnik"]
  s.email       = ["jeff@casimircreative.com", "steve@steveklabnik.com"]
  s.homepage    = "http://github.com/drapergem/draper"
  s.summary     = "View Models for Rails"
  s.description = "Draper adds a nicely-separated object-oriented layer of presentation logic to your Rails apps."
  s.rubyforge_project = "draper"
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'activesupport', '>= 3.0'
  s.add_dependency 'actionpack', '>= 3.0'
  s.add_dependency 'request_store', '~> 1.0.3'

  s.add_development_dependency 'ammeter'
  s.add_development_dependency 'rake', '>= 0.9.2'
  s.add_development_dependency 'rspec', '~> 2.12'
  s.add_development_dependency 'rspec-mocks', '>= 2.12.1'
  s.add_development_dependency 'rspec-rails', '~> 2.12'
  s.add_development_dependency 'minitest-rails', '~> 0.2'
  s.add_development_dependency 'capybara'
end
