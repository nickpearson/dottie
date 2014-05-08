# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'dottie/version'

Gem::Specification.new do |spec|
  spec.name          = "dottie"
  spec.version       = Dottie::VERSION
  spec.authors       = ["Nick Pearson"]
  spec.email         = ["nick@banyantheory.com"]
  spec.summary       = %q{Deep Hash and Array access with dotted keys}
  spec.description   = %q{Deeply access nested Hash/Array data structures
                          without checking for the existence of every node
                          along the way.}
  spec.homepage      = "https://github.com/nickpearson/dottie"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
