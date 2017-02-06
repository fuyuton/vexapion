# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vexapion/version'

Gem::Specification.new do |spec|
  spec.name          = "vexapion"
  spec.version       = Vexapion::VERSION
  spec.authors       = ["fuyuton"]
  spec.email         = ["fuyuton@pastelpink.sakura.ne.jp"]

  spec.summary       = %q{Virtual currency Exchanger API wrapper}
  spec.description   = %q{This is a low layer API wrapper for easy connection to exchanges.}
  spec.homepage      = "https://github.com/fuyuton/vexapion"
  spec.license		 = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  #spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.files         = Dir['{lib}/*.rb', '{lib}/*/*.rb', '{lib}/**/errors/*', '{lib}/**/connect/*']
  #spec.bindir        = "bin"
  #spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files	 = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'bigdecimal', '~> 1.2.6'
  spec.add_runtime_dependency 'json', 		'~> 1.8'

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake',	 '~> 10.0'
end
