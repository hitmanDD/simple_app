class SproutComponent < ViewComponent::Base
  # Подключаем хелпер Turbo, чтобы метод turbo_frame_tag заработал внутри HTML
  include Turbo::FramesHelper

  # Автоматически создаем методы-геттеры для sprout и purchase, чтобы они были доступны в HTML без знака @
  attr_reader :sprout, :purchase

  # Инициализируем компонент, принимая объект ростка и объект покупки (для формы)
  def initialize(sprout:, purchase:)
    @sprout = sprout
    @purchase = purchase
  end

  # Метод форматирования цены (должен быть публичным для шаблона)
  def formatted_price
    price = sprout.respond_to?(:price) ? sprout.price : 100.00
    currency = sprout.respond_to?(:currency) ? sprout.currency : 'RUB'
    
    "#{sprintf('%.2f', price)} #{currency || 'RUB'}"
  end

  # Метод определяет цвет рамки (должен быть публичным для шаблона)
  def badge_class
    case sprout.badge_type
    when 'vip' then 'border-purple-active'
    when 'premium' then 'border-gold-active'
    else 'border-standard'
    end
  end
end