# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pry-state/version'

Gem::Specification.new do |spec|
  spec.name          = "pry-state"
  spec.version       = PryState::VERSION
  spec.authors       = ["Sudhagar"]
  spec.email         = ["sudhagar@isudhagar.in"]
  spec.summary       = 'Shows the state in Pry Session'
  spec.description   = 'Pry state lets you to see the values of the instance and local variables in a pry session'
  spec.homepage      = "https://github.com/SudhagarS/pry-state"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rspec-core'
  spec.add_development_dependency 'pry-nav'
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-rspec'
  spec.add_runtime_dependency 'pry', '> 0.8.10'

end
