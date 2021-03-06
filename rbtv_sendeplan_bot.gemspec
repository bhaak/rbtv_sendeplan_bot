require_relative 'lib/rbtv_sendeplan_bot/version'

Gem::Specification.new do |spec|
  spec.name          = "rbtv_sendeplan_bot"
  spec.version       = RbtvSendeplanBot::VERSION
  spec.authors       = ["Patric Mueller"]
  spec.email         = ["bhaak@gmx.net"]

  spec.summary       = %q{Outputs the RBTV programme schedule}
  spec.homepage      = 'https://github.com/bhaak/rbtv_sendeplan_bot'
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.require_paths = ["lib"]
  spec.bindir        = 'bin'
  spec.executables << 'rbtv_sendeplan_bot'
end

