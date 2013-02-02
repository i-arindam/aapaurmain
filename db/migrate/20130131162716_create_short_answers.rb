class CreateShortAnswers < ActiveRecord::Migration
  def change
    create_table :short_answers do |t|
      t.integer :short_question_id
      t.integer :choice_num
      t.string :text, :limit => 1000

      t.timestamps
    end
    add_index :short_answers, :short_question_id
    add_index :short_answers, [:short_question_id, :choice_num]
  end
end
