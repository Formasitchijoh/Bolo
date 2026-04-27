class CreateQuotes < ActiveRecord::Migration[8.1]
  def change
    create_table :quotes do |t|
      t.references :work_order, null: false, foreign_key: true
      t.references :technician, null: false, foreign_key: true
      t.decimal :price, null: false, precision: 10, scale: 2
      t.string :status, null: false
      t.datetime :approved_at
      t.timestamps
    end
  end
end
