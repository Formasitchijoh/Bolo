class CreateJobs < ActiveRecord::Migration[8.1]
  def change
    create_table :jobs do |t|
      t.references :customer, null: false, foreign_key: true
      t.references :company, foreign_key: false
      t.references :job_category, null: false, foreign_key: true
      t.decimal :latitude, precision: 10, scale: 6, null: false
      t.decimal :longitude, precision: 10, scale: 6, null: false
      t.text :details, null: false
      t.jsonb :media, default: []
      t.decimal :price_range_min, precision: 10, scale: 2, null: false
      t.decimal :price_range_max, precision: 10, scale: 2, null: false
      t.integer :rebroadcast_count, null: false, default: 0
      t.string :status, null: false
      t.timestamps
    end
  end
end
