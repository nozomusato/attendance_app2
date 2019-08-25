class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :name
      t.string :email
      t.integer :employeenumber
      t.integer :card_id
      t.string :note

      t.timestamps
    end
  end
end
