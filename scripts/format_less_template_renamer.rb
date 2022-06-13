require 'pathname'

Pathname.glob("**/*.{haml,erb}").each do |pathname|
  next unless pathname.basename.to_s.match?(/\A\w+\.\w+\z/)

  pathname.rename(
    pathname.to_s.gsub(/\.haml\z/, '.html.haml').gsub(/\.erb\z/, '.html.erb')
  )
end
