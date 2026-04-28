class User < ApplicationRecord
  # Виртуальные атрибуты для токенов (не хранятся в БД напрямую)
  attr_accessor :remember_token, :activation_token, :reset_token

  # Автоматические действия перед сохранением и созданием
  before_save   :downcase_email
  before_create :create_activation_digest

  # Валидации
  validates :name,  presence: true, length: { maximum: 50 }
  validates :bio,   length: { maximum: 500 }
  
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  
  # --- СВЯЗИ (Associations) ---
  # Заметки пользователя
  has_many :notes, dependent: :destroy
  # Микросообщения пользователя (Глава 13)
  # dependent: :destroy гарантирует удаление постов при удалении аккаунта
  has_many :microposts, dependent: :destroy

  # Пароли и их валидация
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  
  # --- МЕТОДЫ КЛАССА ---

  # Возвращает дайджест (хеш) строки
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # Возвращает случайный токен
  def User.new_token
    SecureRandom.urlsafe_base64
  end
  
  # --- МЕТОДЫ ОБЪЕКТА ---

  # Активирует аккаунт
  def activate
    update_attribute(:activated,    true)
    update_attribute(:activated_at, Time.zone.now)
  end
  
  # Забывает пользователя (для выхода из системы)
  def forget
    update_attribute(:remember_digest, nil)
  end

  # --- МЕТОДЫ ДЛЯ СБРОСА ПАРОЛЯ ---

  # Создает токен сброса и записывает время отправки
  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(reset_digest:  User.digest(reset_token), 
                   reset_sent_at: Time.zone.now)
  end

  # Отправляет письмо для сброса пароля
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # Проверяет соответствие токена дайджесту (универсальный метод)
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end
  
  # Проверяет, не протухла ли ссылка (2 часа)
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  private

    # Переводит email в нижний регистр
    def downcase_email
      self.email = email.downcase
    end

    # Создает токен и дайджест активации
    def create_activation_digest
      self.activation_token  = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
end