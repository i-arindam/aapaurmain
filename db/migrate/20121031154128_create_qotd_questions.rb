class CreateQotdQuestions < ActiveRecord::Migration
  def change
    create_table :qotd_questions do |t|
      t.boolean :admin_generated, :default => true
      t.string :question, :limit => 600, :null => false
      t.integer :likes, :default => 0
      t.integer :dislikes, :default => 0
      t.string :question_by_name, :limit => 50, :default => 'admin'
      t.integer :question_by

      t.timestamps
    end
  end
end
