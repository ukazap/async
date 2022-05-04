# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

group :maintenance, optional: true do
	gem "bake-gem"
	gem "bake-modernize"
	
	gem "utopia-project"
end

# gem "async-rspec", path: "../async-rspec"
# gem "rspec-files", path: "../rspec-files"
