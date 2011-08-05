# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "draper/version"

Gem::Specification.new do |s|
  s.name        = "draper"
  s.version     = Draper::VERSION
  s.authors     = ["Jeff Casimir"]
  s.email       = ["jeff@casimircreative.com"]
  s.homepage    = "http://github.com/jcasimir/draper"
  s.summary     = "Decorator pattern implmentation for Rails."
  s.description = "Draper reimagines the role of helpers in the view layer of a Rails application, allowing an object-oriented approach rather than procedural."

  s.rubyforge_project = "draper"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.required_ruby_version = Gem::Requirement.new(">= 1.9.2")

  s.add_development_dependency "rake", "0.8.7"
  s.add_development_dependency "rspec", "~> 2.0.1"
  s.add_development_dependency "activesupport", "~> 3.0.9"
  s.add_development_dependency "actionpack", "~> 3.0.9"
  s.add_development_dependency "ruby-debug19"
  s.add_development_dependency "guard"
  s.add_development_dependency "guard-rspec"
  s.add_development_dependency "rb-fsevent"
  s.add_development_dependency 'cover_me', '>= 1.0.0.rc6'
end
