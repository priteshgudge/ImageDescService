source 'http://rubygems.org'
ruby "2.0.0"

gem 'rails', '3.2.17'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

# gem "sass", "~> 3.2.12"
gem 'thin' # avoids massive memory consumption (as with webrick) on dev machine
gem 'mysql2'
gem 'uuidtools'
gem 'test-unit'
gem 'zipruby'
gem 'aws-sdk'
gem 'cancan'
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem "haml"
gem "paperclip", "~> 3.0"
gem "paperclip-aws"
gem "tire"
gem 'ffi'
gem 'sass-rails', :require => 'sass'
gem 'meta_search', '>= 1.1.0.pre'
gem 'activeadmin', '0.6.2'
# Use unicorn as the web server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger (ruby-debug for Ruby 1.8.7+, ruby-debug19 for Ruby 1.9.2+)
# gem 'ruby-debug'
# gem 'ruby-debug19'

# Bundle the extra gems:
# gem 'bj'
gem 'nokogiri'
# gem 'sqlite3-ruby', :require => 'sqlite3'
# gem 'aws-s3', :require => 'aws/s3'

gem 'image_size'
gem 'parallel'
gem 'delayed_job'
gem 'delayed_job_active_record'
gem 'devise'
gem 'newrelic_rpm'
gem 'kaminari'
gem "airbrake"
gem 'rack-ssl', :require => 'rack/ssl'
gem 'audited-activerecord', '~> 3.0'

# Bundle gems for the local environment. Make sure to
# put test-only gems in this group so their generators
# and rake tasks are available in development mode:
group :development, :test do
#   gem 'webrat'
	gem 'rspec-rails'
	gem 'cucumber-rails', :require => false
	gem 'capybara' # seems to be required by cucumber-rails
	gem 'database_cleaner' # seems to be required by cucumber-rails
  gem 'sqlite3'
  gem 'foreman'
  gem 'oink'
  gem 'factory_girl_rails', '1.2.0'
  gem 'selenium-webdriver'
end
