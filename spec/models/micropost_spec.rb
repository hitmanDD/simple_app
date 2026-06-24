require 'rails_helper'

RSpec.describe Micropost, type: :model do
  # Создаем базовые данные перед каждым тестом
  let!(:user) do 
    User.create!(
      name: "Test User",
      email: "tester@example.com",
      password: "password",
      password_confirmation: "password",
      activated: true,
      activated_at: Time.zone.now
    )
  end
  
  let!(:badge_first) { Badge.create!(name: "Первый шаг", description: "Тест 1", icon: "🌱") }
  let!(:badge_popular) { Badge.create!(name: "Популярный автор", description: "Тест 10", icon: "🔥") }

  # Описываем тестирование колбэка автоматической выдачи
  describe "автоматическая выдача ачивок (callbacks)" do
    
    context "когда пользователь создает самый первый микропост" do
      it "успешно выдает ачивку 'Первый шаг'" do
        expect {
          user.microposts.create!(content: "Мой самый первый пост!")
        }.to change { user.badges.count }.by(1)

        expect(user.badges).to include(badge_first)
      end
    end

    context "когда пользователь создает второй микропост" do
      before do
        user.microposts.create!(content: "Пост номер 1")
      end

      it "не выдает никаких новых ачивок" do
        expect {
          user.microposts.create!(content: "Пост номер 2")
        }.not_to change { user.badges.count }
      end
    end

    context "когда пользователь создает свой 10-й микропост" do
      before do
        9.times { |n| user.microposts.create!(content: "Пост #{n+1}") }
      end

      it "выдает ачивку 'Популярный автор'" do
        expect {
          user.microposts.create!(content: "Ура, это 10-й юбилейный пост!")
        }.to change { user.badges.count }.by(1)

        expect(user.badges).to include(badge_popular)
      end
    end
  end

  # Тестируем метод модели User, который защищает базу от дубликатов
  describe "метод User#award_badge" do
    it "блокирует повторное добавление одной и той же ачивки" do
      user.award_badge(badge_first)

      expect {
        user.award_badge(badge_first)
      }.not_to change { user.badges.count }
    end
  end
end