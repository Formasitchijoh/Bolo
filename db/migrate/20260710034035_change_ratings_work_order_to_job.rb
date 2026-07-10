class ChangeRatingsWorkOrderToJob < ActiveRecord::Migration[8.1]
  def change
    remove_reference :ratings, :work_order, foreign_key: true, null: false
    add_reference :ratings, :job, foreign_key: true, null: false
  end
end
