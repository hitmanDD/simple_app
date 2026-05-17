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
  
  # --- ИСПРАВЛЕННЫЙ БЛОК: ACTIVE STORAGE ДЛЯ АВАТАРОК ---
  # Привязываем одну аватарку к пользователю
  has_one_attached :avatar

  # Кастомная валидация вместо неизвестных Rails валидаторов
  validate :correct_avatar_mime_type_and_size

  # --- СВЯЗИ (Associations) ---
  # Заметки пользователя
  has_many :notes, dependent: :destroy
  # Микросообщения пользователя (Глава 13)
  has_many :microposts, dependent: :destroy
  # Напоминания пользователя (Кастомная фича 2)
  has_many :reminders, dependent: :destroy

  # --- ГЛАВА 14: СВЯЗИ ДЛЯ ПОДПИСОК (Following/Followers) ---
  has_many :active_relationships, class_name:  "Relationship",
                                  foreign_key: "follower_id",
                                  dependent:   :destroy
  has_many :following, through: :active_relationships, source: :followed

  has_many :passive_relationships, class_name:  "Relationship",
                                   foreign_key: "followed_id",
                                   dependent:   :destroy
  has_many :followers, through: :passive_relationships, source: :follower

  # Связи стены
  has_many :wall_comments, class_name: 'Comment', foreign_key: 'wall_owner_id', dependent: :destroy
  has_many :authored_comments, class_name: 'Comment', foreign_key: 'author_id', dependent: :destroy

  # --- НОВЫЙ БЛОК: СИСТЕМА ЛАЙКОВ ---
  # Связь с таблицей лайков: юзер может поставить много лайков разным объектам
  has_many :likes, dependent: :destroy

  # Хелпер-метод: проверяет, поставил ли юзер лайк конкретному объекту
  def liked?(object)
    likes.exists?(likeable: object)
  end
  # ----------------------------------
  # Пароли и их валидация
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true
  
  # --- МЕТОДЫ КЛАССА ---

  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  def User.new_token
    SecureRandom.urlsafe_base64
  end
  
  # --- МЕТОДЫ ОБЪЕКТА ---

  # ХЕЛПЕР ДЛЯ ОТОБРАЖЕНИЯ АВАТАРКИ
  def avatar_display(size = 80)
    if avatar.attached?
      avatar
    else
      gravatar_id = Digest::MD5::hexdigest(email.downcase)
      "https://gravatar.com{gravatar_id}?s=#{size}&d=identicon"
    end
  end

  # НОВАЯ ФИЧА: ПРОВЕРКА СТАТУСА "В СЕТИ"
  # Считаем пользователя онлайн, если он был активен в последние 5 минут
  def online?
    last_seen_at.present? && last_seen_at > 5.minutes.ago
  end

  # ДОБАВЛЕННЫЙ МЕТОД: Форматирование времени последнего входа
  # Показывает "В сети" или "Был(а) в сети ... назад"
  def last_seen_info
    return "Ни разу не был(а) в сети" if last_seen_at.nil?
    
    if online?
      "В сети"
    else
      # Используем хелпер Rails для времени
      "Был(а) в сети #{ActionController::Base.helpers.time_ago_in_words(last_seen_at)} назад"
    end
  end

  def activate
    update_attribute(:activated,    true)
    update_attribute(:activated_at, Time.zone.now)
  end
  
  def forget
    update_attribute(:remember_digest, nil)
  end

  # --- МЕТОДЫ ДЛЯ ПОДПИСОК ---

  def follow(other_user)
    following << other_user unless self == other_user
  end

  def unfollow(other_user)
    following.delete(other_user)
  end

  def following?(other_user)
    following.include?(other_user)
  end

  # === ЛЕНТА НОВОСТЕЙ ===

  def feed
    following_ids_subselect = "SELECT followed_id FROM relationships
                               WHERE follower_id = :user_id"
    
    Micropost.where("user_id IN (#{following_ids_subselect}) OR user_id = :user_id", 
                    user_id: id)
             .includes(:user)
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

    # --- НОВЫЙ МЕТОД: КАСТОМНАЯ ВАЛИДАЦИЯ АВАТАРКИ ---
    def correct_avatar_mime_type_and_size
      if avatar.attached?
        # Проверяем размер файла (должен быть меньше 5 МБ)
        if avatar.blob.byte_size > 5.megabytes
          errors.add(:avatar, "должен быть меньше 5 МБ")
        end

        # Проверяем формат файла
        acceptable_types = ["image/jpeg", "image/gif", "image/png"]
        unless acceptable_types.include?(avatar.content_type)
          errors.add(:avatar, "должен быть корректным форматом изображения")
        end
      end
    end
end