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
  has_many :microposts, dependent: :destroy

  # --- ГЛАВА 14: СВЯЗИ ДЛЯ ПОДПИСОК (Following/Followers) ---
  # Активные связи (на кого подписан текущий юзер)
  has_many :active_relationships, class_name:  "Relationship",
                                  foreign_key: "follower_id",
                                  dependent:   :destroy
  # Список тех, на кого подписан юзер (через активные связи)
  has_many :following, through: :active_relationships, source: :followed

  # Пассивные связи (кто подписан на текущего юзера)
  has_many :passive_relationships, class_name:  "Relationship",
                                   foreign_key: "followed_id",
                                   dependent:   :destroy
  # Список подписчиков (через пассивные связи)
  has_many :followers, through: :passive_relationships, source: :follower

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

  # --- МЕТОДЫ ДЛЯ ПОДПИСОК (Глава 14) ---

  # Подписаться на пользователя
  def follow(other_user)
    following << other_user unless self == other_user
  end

  # Отписаться от пользователя
  def unfollow(other_user)
    following.delete(other_user)
  end

  # Проверка: подписан ли я на этого пользователя?
  def following?(other_user)
    following.include?(other_user)
  end

  # === ЛЕНТА НОВОСТЕЙ (FEED) ДЛЯ ПОЛЬЗОВАТЕЛЯ ===

  # --- НОВЫЙ ВАРИАНТ (Простой SQL-запрос, который мы заменяем) ---
  # def feed
  #   Micropost.where("user_id IN (?) OR user_id = ?", following_ids, id)
  # end

  # --- НОВЫЙ ВАРИАНТ (Оптимизированный SQL-подзапрос) ---
  def feed
    # Выбираем ID подписок прямо в базе через подзапрос (Subselect)
    following_ids_subselect = "SELECT followed_id FROM relationships
                               WHERE follower_id = :user_id"
    
    # Делаем один запрос к БД вместо выгрузки всех ID в память Ruby
    Micropost.where("user_id IN (#{following_ids_subselect}) OR user_id = :user_id", 
                    user_id: id)
             .includes(:user) # Предотвращает проблему N+1 запросов
             .order(created_at: :desc)
  end

  # --- МЕТОДЫ ДЛЯ СБРОСА ПАРОЛЯ ---

  def create_reset_digest
    self.reset_token = User.new_token
    update_columns(reset_digest:  User.digest(reset_token), 
                   reset_sent_at: Time.zone.now)
  end

  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end
  
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  private

    def downcase_email
      self.email = email.downcase
    end

    def create_activation_digest
      self.activation_token  = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
end