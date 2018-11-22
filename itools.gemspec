
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "itools/version"

Gem::Specification.new do |spec|
  spec.name          = "itools"
  spec.version       = Itools::VERSION
  spec.authors       = ["zhanggui"]
  spec.email         = ["scottzg@126.com"]

  spec.summary       = %q{iOS tools}
  spec.description   = %q{iOS dev tools }
  spec.homepage      = "https://github.com/ScottZg/itools"
  spec.license       = "MIT"


  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"

    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/ScottZg/itools"
    spec.metadata["changelog_uri"] = "https://github.com/ScottZg/itools/blob/master/README.md"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.17"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "gli", "~> 2.17"
end
