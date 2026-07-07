# app/components/sprout_component.rb
class SproutComponent < ViewComponent::Base
  # Инициализируем компонент, принимая объект ростка и объект покупки (для формы)
  def initialize(sprout:, purchase:)
    @sprout = sprout
    @purchase = purchase
  end

  private

  # С: форматирование цены инкапсулировано внутри компонента
  def formatted_price
    # Если цена в копейках/центах, делим на 100 для вывода, иначе выводим как есть
    "#{sprintf('%.2f', @sprout.price)} #{@sprout.currency || 'RUB'}"
  end

  # Метод определяет цвет рамки в зависимости от типа ростка
  def badge_class
    case @sprout.badge_type
    when 'vip' then 'border-purple-active'
    when 'premium' then 'border-gold-active'
    else 'border-standard'
    end
  end
end
