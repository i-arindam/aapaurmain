class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.integer   :from_id,       :null => false, :limit => 11
      t.integer   :to_id,         :null => false, :limit => 11
      t.datetime  :ask_time
      t.string    :text
      t.datetime  :response_time
      t.integer   :response_type, :limit => 1
      t.string    :response_text
      t.boolean   :flagged
      t.datetime  :flagged_time
      
      t.timestamps
    end
  end
end
