class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :secret, null: false, unique: true

      t.index :secret, unique: true

      t.timestamps
    end
  end
end
