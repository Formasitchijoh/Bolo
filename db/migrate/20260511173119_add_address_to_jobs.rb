class AddAddressToJobs < ActiveRecord::Migration[8.1]
  def change
    add_column :jobs, :address, :string
  end
end
