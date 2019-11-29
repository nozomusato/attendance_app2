class AddPermitdateToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :permitdate, :date
  end
end
