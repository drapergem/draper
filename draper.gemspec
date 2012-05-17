# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "draper/version"

Gem::Specification.new do |s|
  s.name        = "draper"
  s.version     = Draper::VERSION
  s.authors     = ["Jeff Casimir", "Steve Klabnik"]
  s.email       = ["jeff@casimircreative.com", "steve@steveklabnik.com"]
  s.homepage    = "http://github.com/jcasimir/draper"
  s.summary     = "Decorator pattern implementation for Rails."
  s.description = "Draper implements a decorator or presenter pattern for Rails applications."
  s.rubyforge_project = "draper"
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'activesupport', '~> 3.2'
  s.add_dependency 'actionpack', '~> 3.2'

  s.add_development_dependency 'ammeter', '~> 0.2.2'
  s.add_development_dependency 'guard'
  s.add_development_dependency 'guard-rspec'
  s.add_development_dependency 'launchy'
  s.add_development_dependency 'rake', '~> 0.9.2'
  s.add_development_dependency 'rspec', '~> 2.10'
  s.add_development_dependency 'yard'
end
