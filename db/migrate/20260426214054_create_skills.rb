class CreateSkills < ActiveRecord::Migration[8.1]
  def change
    create_table :skills do |t|
      t.string :name, null: false, index: { unique: true}
      t.references :job_category, null: false, foreign_key: true
      t.timestamps
    end
  end
end
