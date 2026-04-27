class CreateAssignments < ActiveRecord::Migration[8.1]
  def change
    create_table :assignments do |t|
      t.references :job, null: false, foreign_key: true
      t.references :technician, null: false, foreign_key: true
      t.references :company,  foreign_key: true
      t.string :status, null: false
      t.datetime :claim_window, null: false
      t.datetime :assigned_at
      t.datetime :rejected_at
      t.timestamps
    end
  end
end
