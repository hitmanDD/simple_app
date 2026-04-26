class User < ApplicationRecord
  # Виртуальные атрибуты (существуют только в памяти объекта, в БД их нет)
  # reset_token нужен для создания уникальной ссылки, которую мы отправим юзеру
  attr_accessor :remember_token, :activation_token, :reset_token

  # Коллбэки: выполняются автоматически перед сохранением или созданием записи
  before_save   :downcase_email
  before_create :create_activation_digest

  # Валидации данных
  validates :name,  presence: true, length: { maximum: 50 }
  validates :bio,   length: { maximum: 500 }
  
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  
  # Связи: если юзер удален, его заметки (notes) тоже удалятся
  has_many :notes, dependent: :destroy

  # Магия Rails для паролей (bcrypt): добавляет проверку пароля и поле password_digest
  has_secure_password
  # allow_nil: true позволяет обновлять профиль без ввода пароля, 
  # но has_secure_password всё равно не даст создать пустого юзера
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  
  # Статический метод для хеширования строк (используется для дайджестов)
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # Статический метод для генерации случайных токенов (Base64)
  def User.new_token
    SecureRandom.urlsafe_base64
  end
  
  # Активация аккаунта: меняет статус в базе на "активен"
  def activate
    update_attribute(:activated,    true)
    update_attribute(:activated_at, Time.zone.now)
  end

  # --- МЕТОДЫ ДЛЯ СБРОСА ПАРОЛЯ ---

  # 1. Генерируем токен и сохраняем его зашифрованную версию в базу
  def create_reset_digest
    self.reset_token = User.new_token
    # update_columns работает в обход валидаций, записывая данные напрямую в БД
    update_columns(reset_digest:  User.digest(reset_token), 
                   reset_sent_at: Time.zone.now)
  end

  # 2. Вызываем метод мейлера для отправки письма со ссылкой
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # Универсальный метод для проверки токена (активация, сессия или сброс пароля)
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    # Сравниваем пришедший токен с тем, что лежит в базе (через bcrypt)
    BCrypt::Password.new(digest).is_password?(token)
  end
  
  private

    # Приводим email к нижнему регистру перед сохранением (для уникальности)
    def downcase_email
      self.email = email.downcase
    end

    # Создаем токен активации при регистрации нового пользователя
    def create_activation_digest
      self.activation_token  = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
end