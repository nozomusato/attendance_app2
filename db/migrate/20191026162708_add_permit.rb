class AddPermit < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :work_request_permit, :string #承認状態カラム
    add_column :attendances, :edit_request_permit, :string
  end
end
