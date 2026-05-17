class Comment < ApplicationRecord
  # --- СВЯЗИ (Associations) ---
  # Автор комментария (кто написал)
  belongs_to :author, class_name: 'User'
  # Владелец стены (у кого в профиле написан)
  belongs_to :wall_owner, class_name: 'User'

  # --- НОВЫЙ БЛОК: ПОЛИМОРФНЫЕ ЛАЙКИ ---
  # as: :likeable говорит Rails, что этот коммент можно лайкать.
  # При удалении комментария все лайки к нему тоже удалятся (dependent: :destroy).
  has_many :likes, as: :likeable, dependent: :destroy
  # -------------------------------------

  # --- ВАЛИДАЦИИ ---
  # Текст комментария обязателен, длина от 2 до 500 символов
  validates :body, presence: true, length: { minimum: 2, maximum: 500 }
end