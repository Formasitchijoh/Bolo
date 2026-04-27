class CreateShifts < ActiveRecord::Migration[8.1]
  def change
    create_table :shifts do |t|
      t.references :technician, null: false, foreign_key: true
      t.references :company, null: false, foreign_key: true
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false
      t.index [ :technician_id, :start_time, :end_time ]
      t.timestamps
    end
  end
end
