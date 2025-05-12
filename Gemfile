source "https://rubygems.org"

gem "rails", "~> 8.0.2"
gem "propshaft"
gem "puma", ">= 5.0"
gem "tailwindcss-rails", "~> 3.3.1"
gem "jbuilder"
gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "bootsnap", require: false
gem "kamal", require: false
gem "thruster", require: false
gem "httparty"
gem "geocoder"

group :development, :test do
  gem "dotenv-rails"
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
  gem "rspec-rails"
  gem "pry-rails"
  gem "pry-byebug"
end

group :development do
  gem "web-console"
end

group :test do
  gem "webmock"
  gem "rails-controller-testing"
end
