class BadgeProduct < ApplicationRecord
  # --- НАШИ СВЯЗИ: Один продукт-ачивка может иметь множество заказов ---
  has_many :orders, dependent: :destroy

  # --- ВАЛИДАЦИИ: Защита данных на уровне модели ---
  validates :badge_type, presence: true, uniqueness: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :currency, presence: true

  # --- СКОУПЫ: Быстрый фильтр для отображения только доступных в магазине товаров ---
  scope :active, -> { where(active: true) }
end