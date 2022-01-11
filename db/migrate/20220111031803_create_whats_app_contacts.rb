class CreateWhatsAppContacts < ActiveRecord::Migration[7.0]
  def change
    create_table :whats_app_contacts do |t|
      t.string :phone_number

      t.timestamps
    end
  end
end
