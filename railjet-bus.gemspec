# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "railjet/bus/version"

Gem::Specification.new do |spec|
  spec.name          = "railjet-bus"
  spec.version       = Railjet::Bus::VERSION
  spec.authors       = ["Krzysztof Zalewski"]
  spec.email         = ["zlw.zalewski@gmail.com"]

  spec.summary       = %q{Event Bus plugin for Railjet}
  spec.description   = %q{Let's inverse those dependencies}
  spec.homepage      = "https://github.com/nedap/railjet-bus"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency             "railjet",              "~> 2.0.pre3"
  spec.add_dependency             "wisper",               "~> 2.0"
  spec.add_dependency             "wisper-sidekiq",       "~> 0.0.1"

  spec.add_development_dependency "bundler",              "~> 1.11"
  spec.add_development_dependency "rake",                 "~> 11.0"
  spec.add_development_dependency "rspec",                "~> 3.0"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "rake-version",         "~> 1.0"
  spec.add_development_dependency "wisper-testing",       "~> 0.1.0"
  spec.add_development_dependency "wisper-rspec",         "~> 0.0.3"
end
