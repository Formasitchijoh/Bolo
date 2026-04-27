class CreatePayments < ActiveRecord::Migration[8.1]
  def change
    create_table :payments do |t|
      t.references :work_order, null: false, foreign_key: true
      t.decimal :amount, null: false, precision: 10, scale: 2
      t.references :customer, null: false, foreign_key: true
      t.decimal :platform_fee, null: false, precision: 10, scale: 2
      t.decimal :tax, null: false, precision: 10, scale: 2
      t.string :status, null: false
      t.datetime :paid_at
      t.string :reference_id, null: false
      t.string :payment_method, null: false
      t.timestamps
    end
  end
end
