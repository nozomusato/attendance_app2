class Attendance < ApplicationRecord
  belongs_to :user
  validates :worked_on, presence: true
  validate :started_at_none?
  
  def started_at_none?
      if day.started_at.nil? 
       errors.add(:finished_at, ":出勤時間がありません。")
      end
  end
  
end