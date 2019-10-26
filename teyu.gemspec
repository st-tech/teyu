
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "teyu/version"

Gem::Specification.new do |spec|
  spec.name          = "teyu"
  spec.version       = Teyu::VERSION
  spec.authors       = ["Takahiro Kiso (takanamito)", "ZOZO Technologies, Inc."]
  spec.email         = ["takanamito0928@gmail.com"]

  spec.summary       = 'A Ruby class extension for binding initialize method args to instance vars.'
  spec.homepage      = 'https://github.com/st-tech/teyu'
  spec.license       = "MIT"

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", ">= 1.17"
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'test-unit'
  spec.add_development_dependency 'power_assert'
end
