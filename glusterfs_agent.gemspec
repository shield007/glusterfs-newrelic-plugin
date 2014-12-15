# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "glusterfs_newrelic_agent/version"

Gem::Specification.new do |s|
  s.name        = 'glusterfs-agent'
  s.version     = GlusterFSAgent::VERSION
  s.date        = '2014-12-15'
  s.summary     = "A NewRelic Plugin agent for monitoring GlusterFS"
  s.description = "A NewRelic(www.newrelic.com) GlusterFS Server monitor script "
  s.authors     = ["John-Paul Stanford"]
  s.email       = 'dev@stanwood.org.uk'
  s.homepage    = 'https://blah.com'
  s.files         = `git ls-files`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }  
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.licenses    = ['MIT']
  s.has_rdoc     = 'yard'
  s.rdoc_options = [ '--main', 'README.md' ] 
  s.extra_rdoc_files = [ 'LICENSE', 'README.md' ]
  s.add_development_dependency('yard')
  s.add_development_dependency('rake')
  s.add_development_dependency('test-unit')
  s.add_development_dependency('simplecov')     
  s.add_dependency('newrelic_plugin')
  s.require_paths = ["lib"]   
end
