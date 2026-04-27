class CreateCustomers < ActiveRecord::Migration[8.1]
  def change
    create_table :customers do |t|
      t.references :user, null: false, foreign_key: true
      t.string :status, null: false
      t.integer :cancellation_count, null: false, default: 0
      t.timestamps
    end
  end
end
