source 'https://rubygems.org'

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?('/')
  "https://github.com/#{repo_name}.git"
end

ruby '2.5.1'

gem 'rails', '~> 5.2.0.rc2'
gem 'bootsnap', require: false

gem 'rails-i18n'
gem 'puma'

gem 'rack-status'

gem 'pg'
gem 'uniquify'
gem 'paranoia'
gem 'phony_rails'
gem 'apartment', github: 'influitive/apartment', branch: 'development'
gem 'apartment-activejob'

gem 'activeadmin'
gem 'activeadmin_medium_editor'
gem 'formadmin'
gem 'polyamorous'
gem 'ransack'
gem 'cancancan'
gem 'devise'
gem 'devise-i18n'

gem 'turbolinks'
gem 'jquery-turbolinks'
gem 'jquery-ui-rails'
gem 'highcharts-rails'
gem 'momentjs-rails'
gem 'slim'

gem 'uglifier'
gem 'jbuilder'
gem 'sass-rails'
gem 'font-awesome-rails'
gem 'autoprefixer-rails'

gem 'sucker_punch'

gem 'skylight'
gem 'exception_notification'
gem 'exception_notification-rake'

gem 'faraday'
gem 'faraday-cookie_jar'

gem 'postmark'
gem 'gibbon'
gem 'google_drive'
gem 'icalendar'
gem 'prawn'
gem 'prawn-table'
gem 'rubyXL'
gem 'mini_magick'

group :production do
  gem 'redis'
  gem 'hiredis', require: false
  gem 'postmark-rails'
  gem 'aws-sdk-s3', require: false
end

group :development do
  gem 'listen'
  gem 'web-console'
  gem 'letter_opener'
  gem 'bullet'
  gem 'rack-dev-mark'
end

group :development, :test do
  gem 'rspec-rails'
  gem 'capybara'
  gem 'spring-commands-rspec'
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'pdf-inspector', require: 'pdf/inspector'
end

group :test do
  gem 'timecop'
  gem 'vcr'
  gem 'webmock'
end
