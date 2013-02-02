class CreateShortQuestions < ActiveRecord::Migration
  def change
    create_table :short_questions do |t|
      t.string :text, :null => false, :limit => 1000
      t.integer :by_id
      t.string :by, :null => false, :default => "admin"
      t.string :belongs_to_topic, :limit => 50

      t.timestamps
    end
  end
end
