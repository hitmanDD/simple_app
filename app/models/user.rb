class User < ApplicationRecord
  # НОВОЕ: добавляем виртуальный токен (он не сохраняется в базу, но нужен для письма)
  attr_accessor :remember_token, :activation_token

  # НОВОЕ: меняем before_save на более чистый вариант и добавляем создание активации
  before_save   :downcase_email
  before_create :create_activation_digest

  validates :name,  presence: true, length: { maximum: 50 }
  validates :bio,   length: { maximum: 500 }
  
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  
  has_many :notes, dependent: :destroy
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  
  # Возвращает дайджест данной строки
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # НОВОЕ: Возвращает случайный токен (строку)
  def User.new_token
    SecureRandom.urlsafe_base64
  end
  
  # Активирует аккаунт.
  def activate
    update_attribute(:activated,    true)
    update_attribute(:activated_at, Time.zone.now)
  end

  # Возвращает true, если данный токен соответствует дайджесту.
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end
  
  private

    # НОВОЕ: Переводит email в нижний регистр
    def downcase_email
      self.email = email.downcase
    end

    # НОВОЕ: Создает и присваивает активационный токен и дайджест
    def create_activation_digest
      self.activation_token  = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
end