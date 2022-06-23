# frozen_string_literal: true

# Output dependent gems and their versions in TSV format.
#
# Usage:
#
# ```
# ruby scripts/list_gemfile_dependencies.rb
# ```

require 'bundler'
require 'set'

gemfile_lock_path = File.expand_path('Gemfile.lock')
gemfile_lock_content = File.read(gemfile_lock_path)
lock_file_parser = Bundler::LockfileParser.new(gemfile_lock_content)
dependent_gem_names = lock_file_parser.dependencies.keys.to_set
dependent_gem_specs = lock_file_parser.specs.select { |spec| dependent_gem_names.include?(spec.name) }

output = dependent_gem_specs.map do |spec|
  [
    spec.name,
    spec.version
  ].join("\t")
end.join("\n")
puts output
