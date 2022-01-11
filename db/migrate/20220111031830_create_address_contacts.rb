class CreateAddressContacts < ActiveRecord::Migration[7.0]
  def change
    create_table :address_contacts do |t|
      t.text :address

      t.timestamps
    end
  end
end
