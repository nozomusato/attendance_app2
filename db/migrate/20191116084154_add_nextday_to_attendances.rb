class AddNextdayToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :nextday, :boolean, default: false
  end
end
