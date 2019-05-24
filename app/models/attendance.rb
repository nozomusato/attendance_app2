class Attendance < ApplicationRecord
  belongs_to :user
  validates :worked_on, presence: true
  
  
  validate :finished_at_edit_valid
   def finished_at_edit_valid
    if started_at.nil? && finished_at.present?
     errors.add(:finished_at, "出社時間が入力されていません。")
    end
   end
   
  validate :finished_at_cannot_be_faster_than_started_at
  def finished_at_cannot_be_faster_than_started_at
    if  started_at.present? && started_at > finished_at
      errors.add(:finished_at, "退勤時間が出勤時間より早くなっています。")
    end
  end
end