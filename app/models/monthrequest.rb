class Monthrequest < ApplicationRecord
    belongs_to :user
    validates :boss_id, presence: true
end
