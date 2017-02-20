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

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features|unimplement|Gemfile.lock)/}) }
  #spec.files         = Dir['{lib}/*.rb', '{lib}/*/*.rb', '{lib}/**/errors/*', '{lib}/**/connect/*']
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files	 = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake',	 '~> 10.0'
end
