class Topic < ApplicationRecord
  belongs_to :user
  has_many :entry, dependent: :destroy
end
