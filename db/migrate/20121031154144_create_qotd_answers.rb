class CreateQotdAnswers < ActiveRecord::Migration
  def change
    create_table :qotd_answers do |t|
      t.integer :question_id, :null => false
      t.string :answer, :limit => 160, :null => false
      t.integer :answer_by, :null => false
      t.integer :likes, :default => 0
      t.integer :dislikes, :default => 0

      t.timestamps
    end
  end
end
