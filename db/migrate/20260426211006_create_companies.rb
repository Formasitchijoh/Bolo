class CreateCompanies < ActiveRecord::Migration[8.1]
  def change
    create_table :companies do |t|
      t.references :tenant, null: false, foreign_key: true
      t.string :name, null: false
      t.string :email, null: false
      t.string :status, null: false
      t.timestamps
    end
  end
end
