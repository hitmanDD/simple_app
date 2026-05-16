class Like < ApplicationRecord
  belongs_to :user
  belongs_to :likeable, polymorphic: true
  
  # Чтобы нельзя было лайкнуть один объект дважды
  validates :user_id, uniqueness: { scope: [:likeable_id, :likeable_type] }
end