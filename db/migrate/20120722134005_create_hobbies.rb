class CreateHobbies < ActiveRecord::Migration
  def change
    create_table :hobbies do |t|
      t.integer :user_id
      t.string :hobby

      t.timestamps
    end
    add_index :hobbies, :user_id
    add_index :hobbies, :hobby
  end
end
