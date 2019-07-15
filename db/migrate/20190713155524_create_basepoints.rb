class CreateBasepoints < ActiveRecord::Migration[5.1]
  def change
    create_table :basepoints do |t|
      t.string :name
      t.integer :number
      t.string :attendtype

      t.timestamps
    end
  end
end
