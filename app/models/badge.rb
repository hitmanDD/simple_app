class Badge < ApplicationRecord
  # Связь с пользователями через промежуточную таблицу
  has_many :user_badges, dependent: :destroy
  has_many :users, through: :user_badges

  # Валидации
  validates :name, presence: true, uniqueness: true
  validates :icon, presence: true
end