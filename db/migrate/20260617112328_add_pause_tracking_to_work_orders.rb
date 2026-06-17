class AddPauseTrackingToWorkOrders < ActiveRecord::Migration[8.1]
  def change
    add_column :work_orders, :paused_at, :datetime
    add_column :work_orders, :total_paused_seconds, :integer, default: 0, null: false
  end
end
