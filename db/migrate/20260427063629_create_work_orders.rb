class CreateWorkOrders < ActiveRecord::Migration[8.1]
  def change
    create_table :work_orders do |t|
      t.references :assignment, null: false, foreign_key: true
      t.string :status, null: false
      t.datetime :started_at
      t.datetime :completed_at
      t.integer :estimated_time
      t.jsonb :media, default: []
      t.text :notes
      t.timestamps
    end
  end
end
