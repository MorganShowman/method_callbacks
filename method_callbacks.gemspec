# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'method_callbacks/version'

Gem::Specification.new do |spec|
  spec.name          = "method_callbacks"
  spec.version       = MethodCallbacks::VERSION
  spec.authors       = ["Morgan Showman"]
  spec.email         = ["morganshowman@gmail.com"]
  spec.summary       = %q{Add method callbacks to your classes}
  spec.description   = %q{Add after, around, and before callbacks to methods in your classes}
  spec.homepage      = "https://github.com/MorganShowman/method_callbacks"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "guard"
  spec.add_development_dependency "guard-rspec"
end
