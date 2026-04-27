class CreateJobCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :job_categories do |t|
      t.string :name, null: false,  index: { unique: true}
      t.timestamps
    end
  end
end
