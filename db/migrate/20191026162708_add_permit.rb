class AddPermit < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :work_request_permit, :string
    add_column :attendances, :edit_request_permit, :string
  end
end
