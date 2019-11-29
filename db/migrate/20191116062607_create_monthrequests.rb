class CreateMonthrequests < ActiveRecord::Migration[5.1]
  def change
    create_table :monthrequests do |t| #1ヶ月分の勤怠モデル
      t.date :req_date 
      t.string :month_approval
      t.integer :boss_id
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
