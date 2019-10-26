class CreateAdmins < ActiveRecord::Migration[5.0]
  def change
    create_table :admins do |t|
      t.string :first
      t.string :last
      t.string :email
      t.string :password_digest
      t.integer :level
      t.string :reset_hash

      t.timestamps
    end
  end
end
