class CreateTechnicians < ActiveRecord::Migration[8.1]
  def change
    create_table :technicians do |t|
      t.references :user, null: false, foreign_key: true
      t.references :company, foreign_key: true
      t.decimal :latitude, precision: 10, scale: 6, null: false
      t.decimal :longitude, precision: 10, scale: 6, null: false
      t.string :status, null: false
      t.datetime :suspended_until, null: true
      t.boolean :verified, null: false, default: false
      t.decimal :average_rating, null: false, default: 0
      t.timestamps
    end
  end
end
