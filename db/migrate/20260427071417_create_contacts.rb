class CreateContacts < ActiveRecord::Migration[8.1]
  def change
    create_table :contacts do |t|
      t.references :contactable, polymorphic: true, null: false
      t.timestamps
    end
  end
end
