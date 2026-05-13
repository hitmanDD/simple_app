class Comment < ApplicationRecord
  belongs_to :author, class_name: 'User'
  belongs_to :wall_owner, class_name: 'User'

  validates :body, presence: true, length: { minimum: 2, maximum: 500 }
end