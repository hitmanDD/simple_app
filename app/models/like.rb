class Like < ApplicationRecord
  belongs_to :user
  belongs_to :likeable, polymorphic: true

  # --- ОГРАНИЧЕНИЕ: 1 ЛАЙК ОТ 1 ЮЗЕРА ---
  # Проверяем уникальность user_id в паре с объектом лайка
  validates :user_id, uniqueness: { scope: [:likeable_id, :likeable_type], 
                                    message: "уже поставил лайк" }

  # --- НОВЫЙ БЛОК: ТРИГГЕР ДЛЯ АВТОМАТИЧЕСКИХ АЧИВОК ---
  # Этот колбэк срабатывает САМ сразу после успешного создания НОВОГО лайка
  after_create :check_soul_of_company_badge

  private

    # Метод проверки условий для выдачи награды "Душа компании"
    def check_soul_of_company_badge
      # 1. Проверяем, что лайк поставлен именно микропосту
      return unless likeable_type == 'Micropost'

      # 2. Находим автора этого микропоста (через связь belongs_to :user в модели Micropost)
      post_author = likeable.user
      return unless post_author

      # 3. Считаем общее количество лайков на ВСЕХ микропостах этого автора
      # Оптимально: собираем ID всех постов автора и считаем лайки к ним в один запрос
      total_likes_count = Like.where(likeable_type: 'Micropost', 
                                     likeable_id: post_author.microposts.pluck(:id)).count

      # 4. Если общее количество лайков достигло 50 — выдаем корону
      if total_likes_count >= 50
        badge = Badge.find_by(name: "Душа компании")
        post_author.award_badge(badge) if badge
      end
    end
end