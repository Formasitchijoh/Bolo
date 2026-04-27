class CreateServiceTerritories < ActiveRecord::Migration[8.1]
  def change
    create_table :service_territories do |t|
      t.references :company, null: false, foreign_key: true
      t.string :name, null: false
      t.timestamps
    end
  end
end
