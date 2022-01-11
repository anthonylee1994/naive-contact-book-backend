class RemoveRFromUsers < ActiveRecord::Migration[7.0]
  def change
    remove_column :users, :r, :float
  end
end
