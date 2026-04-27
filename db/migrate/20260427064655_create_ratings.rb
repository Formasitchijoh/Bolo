class CreateRatings < ActiveRecord::Migration[8.1]
  def change
    create_table :ratings do |t|
      t.references :work_order, null: false, foreign_key: true
      t.references :technician, null: false, foreign_key: true
      t.references :customer, null: false, foreign_key: true
      t.integer :star, null: false
      t.text :note
      t.timestamps
    end
    add_check_constraint :ratings, "star >= 1 AND star <= 5", name: "valid_star_range"
  end
end
