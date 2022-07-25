# frozen_string_literal: true

# Aggregate total offenses count in .rubocop_todo.yml by day in TSV format.
#
# Usage:
#
# ```
# ruby scripts/aggregate_rubocop_todo_offenses.rb
# ```

require 'date'

days_to_count = 365

days_to_count.times do |i|
  commit_sha = `git log -1 --format='%H' --before=#{i}.day`.rstrip
  rubocop_todo_content = `git show #{commit_sha}:.rubocop_todo.yml`.rstrip
  offenses_count = rubocop_todo_content.scan(/count: (\d+)/).flatten.map(&:to_i).sum
  date = Date.today - i
  puts [
    date,
    offenses_count
  ].join("\t")
end
