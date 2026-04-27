class CreateLineItems < ActiveRecord::Migration[8.1]
  def change
    create_table :line_items do |t|
      t.references :work_order, null: false, foreign_key: true
      t.text :description, null: false
      t.decimal :amount, null: false, precision: 10, scale: 2
      t.timestamps
    end
  end
end
