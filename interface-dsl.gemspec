# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'interface/dsl/version'

Gem::Specification.new do |spec|
  spec.name          = "interface-dsl"
  spec.version       = Interface::Dsl::VERSION
  spec.authors       = ["Oleksiy Kurnenkov"]
  spec.email         = ["o.kurnenkov@gmail.com"]
  spec.licenses      = ['MIT']
  spec.summary       = %q{Interface description DSL}
  spec.description   = %q{Make your Interfaces declarative!}
  spec.homepage      = "https://github.com/o-kurnenkov/interface-dsl"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'dry-validation', '~> 0.10'

  spec.add_runtime_dependency 'hashie', '~> 3.0'
  spec.add_runtime_dependency 'dry-configurable', '~> 0.3'
  spec.add_runtime_dependency 'factorymethods', '~> 1.0'

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
