class CreatePhoneNumbers < ActiveRecord::Migration[8.1]
  def change
    create_table :phone_numbers do |t|
      t.references :contact, null: false, foreign_key: true
      t.string :number, null: false
      t.string :operator, null: false
      t.timestamps
    end
  end
end
