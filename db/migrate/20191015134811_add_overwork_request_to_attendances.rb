class AddOverworkRequestToAttendances < ActiveRecord::Migration[5.1]
  def change #残業申請モーダル項目
    add_column :attendances, :overwork_finish, :datetime #終了予定時間カラム
    add_column :attendances, :overwork_note, :string     #業務処理内容カラム
    add_column :attendances, :overwork_superior, :string #承認者カラム
    add_column :attendances, :next_day, :string          #翌日カラム
  end
end