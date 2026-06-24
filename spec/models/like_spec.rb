
require 'rails_helper'

RSpec.describe Like, type: :model do
  # Создаем двух пользователей: автора постов и того, кто будет лайкать
  let!(:author) do
    User.create!(name: "Author", email: "author@example.com", password: "password", password_confirmation: "password", activated: true)
  end
  
  let!(:liker) do
    User.create!(name: "Liker", email: "liker@example.com", password: "password", password_confirmation: "password", activated: true)
  end

  # Создаем тестовую ачивку
  let!(:badge_soul) { Badge.create!(name: "Душа компании", description: "Тест 50 лайков", icon: "👑") }

  # Создаем один пост автора, на котором будем тестировать лайки
  let!(:micropost) { author.microposts.create!(content: "Пост для лайков") }

  describe "автоматическая выдача ачивки за лайки" do
    
    context "когда автор суммарно получает меньше 50 лайков" do
      it "не выдает ачивку 'Душа компании'" do
        # Имитируем 49 лайков от разных гипотетических пользователей (или одного, если бы позволяла уникальность)
        # Так как у нас валидация уникальности "1 юзер = 1 лайк на пост", для теста проще создать 49 постов и лайкнуть каждый один раз
        49.times do |n|
          p = author.microposts.create!(content: "Пост #{n}")
          Like.create!(user: liker, likeable: p)
        end

        # Проверяем, что у автора всё еще нет короны
        expect(author.badges).not_to include(badge_soul)
      end
    end

    context "когда автор получает 50-й лайк" do
      before do
        # Подготавливаем базу: создаем 49 постов и лайкаем их
        49.times do |n|
          p = author.microposts.create!(content: "Пост #{n}")
          Like.create!(user: liker, likeable: p)
        end
      end

      it "автоматически выдает автору ачивку 'Душа компании'" do
        # Создаем 50-й пост
        final_post = author.microposts.create!(content: "Юбилейный пост")

        # Проверяем, что именно этот 50-й лайк добавит ачивку автору
        expect {
          Like.create!(user: liker, likeable: final_post)
        }.to change { author.badges.count }.by(1)

        expect(author.badges).to include(badge_soul)
      end
    end
  end
end