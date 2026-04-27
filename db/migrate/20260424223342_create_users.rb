class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false, index: { unique: true }
      t.string :password_digest, null: false
      t.string :role, null: false
      t.string :status, null: false, default: 'active'
      t.timestamp :suspended_until, null: true
    end
  end
end
