class CreateNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.references :notifiable, polymorphic: true, null: false
      t.string :title, null: false
      t.text :details, null: false
      t.datetime :read_at
      t.timestamps
    end
  end
end
