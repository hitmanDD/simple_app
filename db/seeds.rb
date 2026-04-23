# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
# Создаем админа
User.create!(name:  "Admin User",
             email: "admin@example.org",
             password:              "password",
             password_confirmation: "password",
             admin: true)

# Генерируем еще 99 случайных ребят
99.times do |n|
  name  = "User-#{n+1}"
  email = "example-#{n+1}@railstutorial.org"
  password = "password"
  User.create!(name:  name,
               email: email,
               password:              password,
               password_confirmation: password)
end