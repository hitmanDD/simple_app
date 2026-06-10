class CreateBadges < ActiveRecord::Migration[7.0]
  def change
    create_table :badges do |t|
      t.string :name, null: false
      t.string :description
      t.string :icon # Сюда будем писать название CSS-класса иконки или emoji

      t.timestamps
    end
  end
end