# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: comana 0.1.2 ruby lib

Gem::Specification.new do |s|
  s.name = "comana"
  s.version = "0.1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["ippei94da"]
  s.date = "2016-05-09"
  s.description = "Comana, COmputation MANAger,\n    is a software to provide a framework of\n    managing scientific computing.\n    Researchers on computing have to check calculation and\n    generate new calculation and execute, repeatedly.\n    The abstract class that this gem provide would help the work.\n  "
  s.email = "ippei94da@gmail.com"
  s.executables = ["genqsub", "hostinfo", "scpall", "sshall"]
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    ".rspec",
    "CHANGES",
    "Gemfile",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "bin/genqsub",
    "bin/hostinfo",
    "bin/scpall",
    "bin/sshall",
    "comana.gemspec",
    "example/dot.clustersetting",
    "lib/comana.rb",
    "lib/comana/clustersetting.rb",
    "lib/comana/computationmanager.rb",
    "lib/comana/gridengine.rb",
    "lib/comana/hostinspector.rb",
    "lib/comana/hostselector.rb",
    "test/gridengine/qconfsql.dat",
    "test/gridengine/qstatf0.xml",
    "test/gridengine/qstatf1.xml",
    "test/gridengine/qstatq0.xml",
    "test/gridengine/qstatq1.xml",
    "test/gridengine/qstatu0.xml",
    "test/gridengine/qstatu1.xml",
    "test/helper.rb",
    "test/hostinspector/.gitignore",
    "test/hostselector/dot.clustersetting",
    "test/locked/input_a",
    "test/locked/input_b",
    "test/locked/lock_comana/dummy",
    "test/locked_outputted/input_a",
    "test/locked_outputted/input_b",
    "test/locked_outputted/lock_comana/dummy",
    "test/locked_outputted/output",
    "test/not_executable/dummy",
    "test/not_started/input_a",
    "test/not_started/input_b",
    "test/outputted/input_a",
    "test/outputted/input_b",
    "test/outputted/output",
    "test/pbsnodes/Br09.xml",
    "test/pbsnodes/Br10.xml",
    "test/pbsnodes/Ge00.xml",
    "test/pbsnodes/Ge08.xml",
    "test/pbsnodes/all.xml",
    "test/queuesubmitter/locked/lock_queuesubmitter/dummy",
    "test/queuesubmitter/unlocked/dummy",
    "test/test_clustersetting.rb",
    "test/test_computationmanager.rb",
    "test/test_gridengine.rb",
    "test/test_hostinspector.rb",
    "test/test_hostselector.rb"
  ]
  s.homepage = "http://github.com/ippei94da/comana"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.5.1"
  s.summary = "Manager for scientific computing"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<test-unit>, ["~> 3.1"])
      s.add_development_dependency(%q<rdoc>, ["~> 4.2"])
      s.add_development_dependency(%q<bundler>, ["~> 1.11"])
      s.add_development_dependency(%q<jeweler>, ["~> 2.0"])
      s.add_development_dependency(%q<simplecov>, ["~> 0.11"])
      s.add_development_dependency(%q<tefil>, ["~> 0.1"])
      s.add_development_dependency(%q<builtinextension>, ["~> 0.1"])
    else
      s.add_dependency(%q<test-unit>, ["~> 3.1"])
      s.add_dependency(%q<rdoc>, ["~> 4.2"])
      s.add_dependency(%q<bundler>, ["~> 1.11"])
      s.add_dependency(%q<jeweler>, ["~> 2.0"])
      s.add_dependency(%q<simplecov>, ["~> 0.11"])
      s.add_dependency(%q<tefil>, ["~> 0.1"])
      s.add_dependency(%q<builtinextension>, ["~> 0.1"])
    end
  else
    s.add_dependency(%q<test-unit>, ["~> 3.1"])
    s.add_dependency(%q<rdoc>, ["~> 4.2"])
    s.add_dependency(%q<bundler>, ["~> 1.11"])
    s.add_dependency(%q<jeweler>, ["~> 2.0"])
    s.add_dependency(%q<simplecov>, ["~> 0.11"])
    s.add_dependency(%q<tefil>, ["~> 0.1"])
    s.add_dependency(%q<builtinextension>, ["~> 0.1"])
  end
end

