class Like < ApplicationRecord
  belongs_to :user
  belongs_to :likeable, polymorphic: true

  # --- ОГРАНИЧЕНИЕ: 1 ЛАЙК ОТ 1 ЮЗЕРА ---
  # Проверяем уникальность user_id в паре с объектом лайка
  validates :user_id, uniqueness: { scope: [:likeable_id, :likeable_type], 
                                    message: "уже поставил лайк" }
end