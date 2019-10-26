class CreatePropertyCodes < ActiveRecord::Migration[5.0]
  def change
    create_table :property_codes do |t|
      t.string :code
      t.text :conditions
      t.string :garment

      t.timestamps
    end
    add_index :property_codes, :garment
  end
end
