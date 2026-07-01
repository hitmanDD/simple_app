class CreateMonetizationTables < ActiveRecord::Migration[7.0]
  def change
    # Привязываем цены к типам ачивок
    create_table :badge_products do |t|
      t.string :badge_type, null: false, index: { unique: true }
      t.decimal :price, precision: 10, scale: 2, null: false
      t.string :currency, null: false, default: 'USD' # USD, RUB
      t.boolean :active, default: true, null: false

      t.timestamps
    end

    # Таблица заказов
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.references :badge_product, null: false, foreign_key: true
      t.string :status, null: false, default: 'pending' # pending, completed, failed
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :currency, null: false
      t.string :payment_provider, null: false # 'stripe', 'yookassa'
      t.string :provider_order_id, index: { unique: true } # ID транзакции из платежки для идемпотентности

      t.timestamps
    end
  end
end