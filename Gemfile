source 'https://rubygems.org'

# Distribute your app as a gem
# gemspec

# Server requirements
# gem 'thin' # or mongrel
# gem 'trinidad', :platform => 'jruby'

# Optional JSON codec (faster performance)
# gem 'oj'

# Project requirements
gem 'rake'
gem 'activesupport', '4.1.8'

# Component requirements
gem 'haml'
gem 'mongoid'

# Test requirements
gem 'rspec', :group => 'test'
gem 'rack-test', :require => 'rack/test', :group => 'test'

# Padrino Stable Gem
gem 'padrino', '0.12.4'
gem 'bunny'
gem 'nokogiri'
gem 'forkr', '0.1.5'

# Or Padrino Edge
# gem 'padrino', :github => 'padrino/padrino-framework'

# Or Individual Gems
# %w(core support gen helpers cache mailer admin).each do |g|
#   gem 'padrino-' + g, '0.12.4'
# end
group :production do
  gem 'unicorn'
#  gem 'bluepill', '0.0.68'
  gem 'eye'
end

group :development do
  gem 'capistrano', '3.2.1'
  gem 'capistrano-scm-gitcopy', '0.0.7'
  gem 'capistrano-bundler'
end

gem 'nokogiri-happymapper', :require => 'happymapper'
