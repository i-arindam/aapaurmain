class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.integer :conversation_id, :limit => 11, :null => false
      t.string :text, :limit => 3000, :null => false
      t.integer :from, :limit => 11, :null => false
      t.integer :to, :limit => 11, :null => false
      t.timestamps
    end
  end
end
