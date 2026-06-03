class WallComment < ApplicationRecord
  # Связи-алиасы (Middle-уровень: разделяем роли пользователей)
  belongs_to :wall_owner, class_name: 'User', foreign_key: 'wall_owner_id'
  belongs_to :author, class_name: 'User', foreign_key: 'author_id'

  # Связи для системы лайков
  # зависимость dependent: :destroy удалит лайки из базы, если удалить сам комментарий
  has_many :likes, dependent: :destroy

  # Бэкенд-валидация: защищаем базу данных от пустых или слишком длинных текстов
  validates :body, presence: true, length: { maximum: 500, message: "не может превышать 500 символов" }

  # Метод-помощник для View: быстро проверяет, ставил ли лайк конкретный пользователь
  def liked_by?(user)
    return false if user.nil? # Защита от неавторизованных гостей
    likes.exists?(user_id: user.id)
  end
end