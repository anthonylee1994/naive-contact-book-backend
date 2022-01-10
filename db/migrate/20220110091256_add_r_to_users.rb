class AddRToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :r, :float
  end
end
