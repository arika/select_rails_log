# frozen_string_literal: true

require_relative "lib/select_rails_log/version"

Gem::Specification.new do |spec|
  spec.name = "select_rails_log"
  spec.version = SelectRailsLog::VERSION
  spec.authors = ["akira yamada"]
  spec.email = ["akira@arika.org"]

  spec.summary = "Rails log selector"
  spec.description = "select_rails_log is a tool for extracting request logs from Rails log files."
  spec.homepage = "https://github.com/arika/select_rails_log"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/arika/select_rails_log"
  spec.metadata["changelog_uri"] = "https://github.com/arika/select_rails_log/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "csv"
  spec.add_dependency "enumerable-statistics"
  spec.add_dependency "unicode_plot"
end
