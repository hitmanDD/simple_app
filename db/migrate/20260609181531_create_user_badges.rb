class CreateUserBadges < ActiveRecord::Migration[7.0]
  def change
    create_table :user_badges do |t|
      t.references :user, null: false, foreign_key: true
      t.references :badge, null: false, foreign_key: true

      t.timestamps
    end

    # Гарантируем на уровне базы данных, что пользователь не получит одну и ту же ачивку дважды
    add_index :user_badges, [:user_id, :badge_id], unique: true
  end
end