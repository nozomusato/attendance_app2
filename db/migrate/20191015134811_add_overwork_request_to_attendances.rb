class AddOverworkRequestToAttendances < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :overwork_finish, :datetime
    add_column :attendances, :overwork_note, :string
    add_column :attendances, :overwork_superior, :string
    add_column :attendances, :next_day, :string
  end
end