# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dynamite/version'

Gem::Specification.new do |spec|
  spec.name          = "dynamo-dynamite"
  spec.version       = Dynamite::VERSION
  spec.authors       = ["Jason Strutz"]
  spec.email         = ["j@jasonstrutz.com"]
  spec.summary       = %q{An object mapper for Amazon's DynamoDB}
  spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'aws-sdk-core', '~> 2.0.0.pre'

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "guard-minitest"
end
