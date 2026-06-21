# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

puts "Начало генерации данных..."

# 1. Создаем админа (используем find_or_create_by для безопасности)
admin = User.find_or_create_by!(email: "admin@example.org") do |u|
  u.name = "Admin User"
  u.password = "password"
  u.password_confirmation = "password"
end

# Принудительно активируем админа и даем права (защита от ошибок базы данных)
admin.update_columns(activated: true, activated_at: Time.zone.now)
admin.update_column(:admin, true) if admin.respond_to?(:admin)

# 2. Генерируем еще 99 случайных пользователей
99.times do |n|
  email = "example-#{n+1}@railstutorial.org"
  
  user = User.find_or_create_by!(email: email) do |u|
    u.name = "User-#{n+1}"
    u.password = "password"
    u.password_confirmation = "password"
  end
  
  # Автоматически активируем каждого пользователя, чтобы обойти validation/callback активации
  user.update_columns(activated: true, activated_at: Time.zone.now)
end

puts "Пользователи успешно созданы/проверены!"

# 3. Создаем систему ачивок
Badge.find_or_create_by!(name: "Первый шаг") do |b|
  b.description = "Создал свой первый микропост"
  b.icon = "🌱"
end

Badge.find_or_create_by!(name: "Популярный автор") do |b|
  b.description = "Написал 10 микропостов"
  b.icon = "🔥"
end

Badge.find_or_create_by!(name: "Душа компании") do |b|
  b.description = "Собрал 50 лайков на своих записях"
  b.icon = "👑"
end

puts "Ачивки успешно добавлены! Все готово."