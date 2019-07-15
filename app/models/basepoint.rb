class Basepoint < ApplicationRecord
    
    validates :name, presence: true
    validates :number, presence: true
    validates :attendtype, presence: true
end
