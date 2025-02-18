source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "active_model_serializers"
gem "api-pagination", "~> 5.0"
gem "bootsnap", require: false
gem "kaminari", "~> 1.2"
gem "logger"
gem "nokogiri", "1.16.5"
gem "okcomputer"
gem "pg"
gem "rails", "~> 7.0.8"
gem "rake"
gem "rswag"
gem "puma", "~> 5.6"
gem "traject", "3.8.2"
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
# gem "jbuilder"

# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem "rack-cors"


group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  gem "rspec-rails"
  gem "byebug", platform: :mri
  gem "pry-rails"
  gem "capybara"
  gem 'database_cleaner-active_record'
end

group :development do
  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end
