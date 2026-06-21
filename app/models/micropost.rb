class Micropost < ApplicationRecord
  belongs_to :user
  
  # Сортируем сообщения: сначала самые новые
  default_scope -> { order(created_at: :desc) }
  
  # Валидации
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }

  # --- НОВЫЙ БЛОК: ТРИГГЕР ДЛЯ АВТОМАТИЧЕСКИХ АЧИВОК ---
  # Этот колбэк срабатывает САМ сразу после успешного создания НОВОГО микропоста
  after_create :check_and_award_badges

  private

    # Метод проверки условий для выдачи наград
    def check_and_award_badges
      # Считаем, сколько всего постов у автора на данный момент
      posts_count = user.microposts.count

      # 1. Проверяем ачивку за самый первый пост
      if posts_count == 1
        badge = Badge.find_by(name: "Первый шаг")
        user.award_badge(badge) if badge
      end

      # 2. Проверяем ачивку за 10 постов
      if posts_count == 10
        badge = Badge.find_by(name: "Популярный автор")
        user.award_badge(badge) if badge
      end
    end
end