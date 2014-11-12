# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
#require "knife/profitbricks"

Gem::Specification.new do |s|
  s.name        = "knife-profitbricks"
  s.version     = "0.3.2"
  s.authors     = ["Kishorekumar Neelamegam, Thomas Alrin"]
  s.email       = ["nkishore@megam.co.in","alrin@megam.co.in"]
  s.homepage    = "http://github.com/indykish/knife-profitbricks"
  s.license = "Apache V2"
  s.extra_rdoc_files = ["README.md", "LICENSE" ]
  s.summary     = %q{Knife Client for Profitbricks cloud}
  s.description = %q{Knife Client for Profitbricks cloud. If you wish to use Chef with Profitbricks an awesome cloud}
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  s.add_runtime_dependency 'profitbricks'
  #s.add_runtime_dependency 'hoe'
  s.add_runtime_dependency 'chef'
end
