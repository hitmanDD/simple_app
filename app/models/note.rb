class Note < ApplicationRecord
  # Устанавливаем связь: каждая заметка принадлежит конкретному пользователю
  belongs_to :user 
  
  # Сортировка по умолчанию: новые заметки будут отображаться первыми (добавлено для тестов)
  default_scope -> { order(created_at: :desc) }

  # Валидация: текст заметки обязателен и не может быть длиннее 140 символов
  validates :content, presence: true, length: { maximum: 140 }

  # Валидация: идентификатор пользователя должен обязательно присутствовать
  validates :user_id, presence: true
end