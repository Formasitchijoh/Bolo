class CreateTechnicianSkills < ActiveRecord::Migration[8.1]
  def change
    create_table :technician_skills do |t|
      t.references :technician, null: false, foreign_key: true
      t.references :skill, null: false, foreign_key: true
      t.timestamps
    end
  end
end
