class Order < ApplicationRecord
  include AASM

  # --- СВЯЗИ МОДЕЛИ ---
  belongs_to :user
  belongs_to :badge_product

  # --- ВАЛИДАЦИИ ---
  validates :amount, :currency, :payment_provider, presence: true

  # --- СТЕЙТ-МАШИНА УПРАВЛЕНИЯ СТАТУСАМИ ЗАКАЗА ---
  aasm column: :status do
    state :pending, initial: true
    state :completed, :failed

    event :complete do
      # Используем after для вызова бизнес-логики ПОСЛЕ коммита транзакции
      transitions from: :pending, to: :completed, after: :award_badge_and_notify!
    end

    event :fail do
      transitions from: :pending, to: :failed
    end
  end

  private

  def award_badge_and_notify!
    # Вызываем асинхронную джобу, чтобы не держать вебхук платежки
    Orders::CompleteJob.perform_later(id)
  end
end