class CreateTechnicianCompanies < ActiveRecord::Migration[8.1]
  def change
    create_table :technician_companies do |t|
      t.references :technician, null: false, foreign_key: true
      t.references :company, null: false, foreign_key: true
      t.string :status, null: false
      t.timestamps
    end
  end
end
