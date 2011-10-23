# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "draper/version"

Gem::Specification.new do |s|
  s.name        = "draper"
  s.version     = Draper::VERSION
  s.authors     = ["Jeff Casimir"]
  s.email       = ["jeff@casimircreative.com"]
  s.homepage    = "http://github.com/jcasimir/draper"
  s.summary     = "Decorator pattern implementation for Rails."
  s.description = "Draper reimagines the role of helpers in the view layer of a Rails application, allowing an object-oriented approach rather than procedural."

  s.rubyforge_project = "draper"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
