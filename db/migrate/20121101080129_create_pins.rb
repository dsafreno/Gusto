class CreatePins < ActiveRecord::Migration
  def change
    create_table :pins do |t|
      t.decimal :latitude
      t.decimal :longitude
      t.integer :user_id

      t.timestamps
    end
  end
end
