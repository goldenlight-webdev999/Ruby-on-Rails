class CreateCsvCodes < ActiveRecord::Migration[5.0]
  def change
    create_table :csv_codes do |t|
      t.string :garment
      t.string :code
      t.string :property
      t.text :values

      t.timestamps
    end
  end
end
