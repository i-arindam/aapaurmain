# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130305180157) do

  create_table "add_users_to_searches", :force => true do |t|
    t.string   "name",                    :limit => 50,                 :null => false
    t.integer  "family_preference",       :limit => 2
    t.integer  "spouse_preference",       :limit => 2
    t.string   "further_education_plans", :limit => 500
    t.string   "settle_else",             :limit => 500
    t.integer  "sexual_preference",       :limit => 2,   :default => 0
    t.string   "virginity_opinion",       :limit => 500
    t.string   "hobbies",                 :limit => 500
    t.integer  "profession",              :limit => 2
    t.string   "dream_for_future",        :limit => 500
    t.string   "settled_in"
    t.datetime "created_at",                                            :null => false
    t.datetime "updated_at",                                            :null => false
  end

  create_table "conversations", :force => true do |t|
    t.integer  "from_user_id",                :null => false
    t.integer  "to_user_id",                  :null => false
    t.string   "snippet",      :limit => 100
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
  end

  create_table "couples", :force => true do |t|
    t.integer  "one_id",                         :null => false
    t.integer  "another_id",                     :null => false
    t.integer  "deliberation_time", :limit => 2
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "messages", :force => true do |t|
    t.integer  "conversation_id",                 :null => false
    t.string   "text",            :limit => 3000, :null => false
    t.integer  "from",                            :null => false
    t.integer  "to",                              :null => false
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  create_table "profile_updates", :force => true do |t|
    t.text     "profile"
    t.integer  "status",     :default => 0
    t.integer  "user_id"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  create_table "qotd_answers", :force => true do |t|
    t.integer  "question_id",                               :null => false
    t.string   "answer",      :limit => 160,                :null => false
    t.integer  "answer_by",                                 :null => false
    t.integer  "likes",                      :default => 0
    t.integer  "dislikes",                   :default => 0
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  create_table "qotd_questions", :force => true do |t|
    t.boolean  "admin_generated",                 :default => true
    t.string   "question",         :limit => 600,                      :null => false
    t.integer  "likes",                           :default => 0
    t.integer  "dislikes",                        :default => 0
    t.string   "question_by_name", :limit => 50,  :default => "admin"
    t.integer  "question_by"
    t.datetime "created_at",                                           :null => false
    t.datetime "updated_at",                                           :null => false
  end

  create_table "questions", :force => true do |t|
    t.integer  "from_id",                    :null => false
    t.integer  "to_id",                      :null => false
    t.datetime "ask_time"
    t.string   "text"
    t.datetime "response_time"
    t.integer  "response_type", :limit => 1
    t.string   "response_text"
    t.boolean  "flagged"
    t.datetime "flagged_time"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  create_table "remove_users_from_searches", :id => false, :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "requests", :force => true do |t|
    t.integer  "from_id",                                   :null => false
    t.integer  "to_id",                                     :null => false
    t.integer  "status",        :limit => 1, :default => 0
    t.datetime "approved_date"
    t.datetime "rejected_date"
    t.datetime "asked_date"
    t.datetime "withdraw_date"
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  add_index "requests", ["from_id"], :name => "index_requests_on_from_id"
  add_index "requests", ["to_id"], :name => "index_requests_on_to_id"

  create_table "short_answers", :force => true do |t|
    t.integer  "short_question_id"
    t.integer  "choice_num"
    t.string   "text",              :limit => 1000
    t.datetime "created_at",                        :null => false
    t.datetime "updated_at",                        :null => false
  end

  add_index "short_answers", ["short_question_id", "choice_num"], :name => "index_short_answers_on_short_question_id_and_choice_num"
  add_index "short_answers", ["short_question_id"], :name => "index_short_answers_on_short_question_id"

  create_table "short_questions", :force => true do |t|
    t.string   "text",             :limit => 1000,                      :null => false
    t.integer  "by_id"
    t.string   "by",                               :default => "admin", :null => false
    t.string   "belongs_to_topic", :limit => 50
    t.datetime "created_at",                                            :null => false
    t.datetime "updated_at",                                            :null => false
  end

  create_table "user_follows", :force => true do |t|
    t.integer  "user_id"
    t.integer  "following_user_id",                             :null => false
    t.integer  "follow_type",       :limit => 1, :default => 0
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
  end

  add_index "user_follows", ["following_user_id", "user_id"], :name => "index_user_follows_on_following_user_id_and_user_id", :unique => true
  add_index "user_follows", ["user_id", "following_user_id"], :name => "index_user_follows_on_user_id_and_following_user_id", :unique => true

  create_table "users", :force => true do |t|
    t.string   "email",                                                                                :null => false
    t.string   "name",                   :limit => 150,                                                :null => false
    t.date     "dob"
    t.string   "location"
    t.string   "password_reset_token"
    t.date     "password_reset_sent_at"
    t.string   "password_digest",                                                                      :null => false
    t.string   "auth_token"
    t.integer  "sex",                    :limit => 1
    t.string   "relocation",             :limit => 140
    t.string   "joint_family",           :limit => 140
    t.string   "inlaws_interference",    :limit => 140
    t.string   "further_education",      :limit => 140
    t.string   "kids",                   :limit => 140
    t.string   "opinion_on_sex",         :limit => 140
    t.string   "gender_expectations",    :limit => 140
    t.string   "primary_bread_winner",   :limit => 140
    t.string   "independence",           :limit => 140
    t.string   "career_priority",        :limit => 140
    t.string   "financial_stability",    :limit => 140
    t.string   "romance",                :limit => 140
    t.string   "interests",              :limit => 140
    t.string   "virginity",              :limit => 140
    t.string   "chivalry",               :limit => 140
    t.string   "decisiveness",           :limit => 140
    t.string   "family_background",      :limit => 140
    t.string   "short_bio",              :limit => 500
    t.string   "photo_url"
    t.boolean  "photo_exists"
    t.boolean  "email_verified"
    t.date     "locked_since"
    t.integer  "locked_with"
    t.boolean  "status"
    t.datetime "created_at",                                                                           :null => false
    t.datetime "updated_at",                                                                           :null => false
    t.integer  "num_ratings",                                                         :default => 0
    t.decimal  "avg_rating",                            :precision => 4, :scale => 2, :default => 0.0
  end

  add_index "users", ["auth_token"], :name => "index_users_on_auth_token"
  add_index "users", ["email"], :name => "index_users_on_email"
  add_index "users", ["location"], :name => "index_users_on_location"
  add_index "users", ["password_reset_token"], :name => "index_users_on_password_reset_token"

end
