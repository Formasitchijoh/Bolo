class AddTitleToJobs < ActiveRecord::Migration[8.1]
  def change
    add_column :jobs, :title, :string, null: false, default: "Untitled"
    change_column_default :jobs, :title, nil
  end
end
