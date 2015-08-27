Gem::Specification.new do |s|

  s.name            = 'logstash-filter-translate_cidr'
  s.version         = '0.1.0'
  s.licenses        = ['Apache License (2.0)']
  s.summary         = "A general search and replace tool which uses a configured hash and/or a YAML file to determine replacement values using (optionally) cidr as key."
  s.description     = "This gem is a logstash plugin required to be installed on top of the Logstash core pipeline using $LS_HOME/bin/plugin install gemname. This gem is not a stand-alone program"
  s.authors         = ["PERT Consultores SRL"]
  s.email           = 'adriano@pert.com.ar'
#  s.homepage        = "http://www.pert.com.ar/"
  s.require_paths = ["lib"]

  # Files
  s.files = `git ls-files`.split($\)

  # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { "logstash_plugin" => "true", "logstash_group" => "filter" }

  # Gem dependencies
  s.add_runtime_dependency "logstash-core", '>= 1.4.0', '< 2.0.0'

  s.add_development_dependency 'logstash-devutils'
end

