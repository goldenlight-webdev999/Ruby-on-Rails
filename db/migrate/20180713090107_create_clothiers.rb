class CreateClothiers < ActiveRecord::Migration[5.0]
  def change
    create_table :clothiers do |t|
      t.string :first
      t.string :last
      t.string :email
      t.string :showroom
      t.boolean :active
      t.string :password_digest
      t.string :reset_hash

      t.timestamps
    end
  end
end
