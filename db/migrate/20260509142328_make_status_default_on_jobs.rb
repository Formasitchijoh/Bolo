class MakeStatusDefaultOnJobs < ActiveRecord::Migration[8.1]
  def change
      change_column_default :jobs, :status, "available"
  end
end
