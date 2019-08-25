class CreateOvertimes < ActiveRecord::Migration[5.1]
  def change
    create_table :overtimes do |t|
      t.string :expectation_finished_at
      t.string :note
      t.timestamps
    end
  end
  
end
