source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.0.4"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.0.4"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 5.0"

# Bundle and transpile JavaScript [https://github.com/rails/jsbundling-rails]
gem "jsbundling-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Bundle and process CSS [https://github.com/rails/cssbundling-rails]
gem "cssbundling-rails"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Глобальные гемы, доступные во всех окружениях
gem 'will_paginate'
gem 'sassc-rails'
gem "importmap-rails"
gem 'pagy', '~> 5.10'

# =========================================================================
# ОКРУЖЕНИЕ: ОБЩЕЕ ДЛЯ РАЗРАБОТКИ И ТЕСТИРОВАНИЯ (DEVELOPMENT & TEST)
# =========================================================================
group :development, :test do
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  gem 'rails-controller-testing'
  gem 'rspec-rails', '~> 7.0' 
end

# =========================================================================
# ОКРУЖЕНИЕ: СТРОГО ДЛЯ РАЗРАБОТКИ (DEVELOPMENT ONLY)
# =========================================================================
group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  # ИСПРАВЛЕНО: Теперь гем изолирован и не будет взрывать тестовую среду
  gem "web-console"
  gem 'letter_opener'
end

# =========================================================================
# ОКРУЖЕНИЕ: СТРОГО ДЛЯ ТЕСТИРОВАНИЯ (TEST ONLY)
# =========================================================================
group :test do
  # Добавляем capybara для поддержки System Specs
  gem 'capybara'
end

# Гем для сервисного слоя и удобной обработки ошибок
gem 'simple_command'

# Гем для стейт-машины управления статусами заказов
gem 'aasm'