class AddConfchange < ActiveRecord::Migration[5.1]
  def change
    add_column :attendances, :conf_change, :integer
    add_column :attendances, :origin_start, :datetime
    add_column :attendances, :origin_fin, :datetime
  end
end
