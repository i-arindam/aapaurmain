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

ActiveRecord::Schema.define(:version => 20120916133924) do

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

  create_table "hobbies", :force => true do |t|
    t.integer  "user_id"
    t.string   "hobby"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "hobbies", ["hobby"], :name => "index_hobbies_on_hobby"
  add_index "hobbies", ["user_id"], :name => "index_hobbies_on_user_id"

  create_table "interested_in", :force => true do |t|
    t.integer  "user_id"
    t.string   "interested"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "interested_in", ["interested"], :name => "index_interested_in_on_interested"
  add_index "interested_in", ["user_id"], :name => "index_interested_in_on_user_id"

  create_table "locks", :force => true do |t|
    t.integer "one_id",                                    :null => false
    t.integer "another_id",                                :null => false
    t.date    "creation_date"
    t.date    "date"
    t.date    "withdraw_date"
    t.date    "finalize_date"
    t.integer "status",        :limit => 1, :default => 0
  end

  add_index "locks", ["another_id"], :name => "index_locks_on_another_id"
  add_index "locks", ["one_id"], :name => "index_locks_on_one_id"

  create_table "messages", :force => true do |t|
    t.integer  "conversation_id",                 :null => false
    t.string   "text",            :limit => 3000, :null => false
    t.integer  "from",                            :null => false
    t.integer  "to",                              :null => false
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  create_table "not_interested_in", :force => true do |t|
    t.integer  "user_id"
    t.string   "not_interested"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "not_interested_in", ["not_interested"], :name => "index_not_interested_in_on_not_interested"
  add_index "not_interested_in", ["user_id"], :name => "index_not_interested_in_on_user_id"

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

  create_table "subscriptions", :force => true do |t|
    t.date     "start_date",                                    :null => false
    t.date     "end_date",                                      :null => false
    t.integer  "subs_type",         :limit => 1, :default => 0
    t.date     "remind_date_start"
    t.integer  "user_id"
    t.date     "renew_date"
    t.integer  "renew_type",        :limit => 1, :default => 0
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.integer  "status",            :limit => 1, :default => 0
  end

  add_index "subscriptions", ["end_date"], :name => "index_subscriptions_on_end_date"
  add_index "subscriptions", ["remind_date_start"], :name => "index_subscriptions_on_remind_date_start"
  add_index "subscriptions", ["user_id"], :name => "fk_subscriptions_users"

  create_table "user_flags", :force => true do |t|
    t.integer  "user_id",                 :null => false
    t.integer  "value",      :limit => 2
    t.datetime "created_at",              :null => false
    t.datetime "updated_at",              :null => false
  end

  add_index "user_flags", ["user_id"], :name => "fk_user_flags_users"

  create_table "users", :force => true do |t|
    t.string   "name",                       :limit => 50
    t.date     "dob"
    t.string   "sex",                        :limit => 10
    t.integer  "family_preference",          :limit => 2
    t.float    "height"
    t.integer  "spouse_preference",          :limit => 2
    t.integer  "spouse_salary",              :limit => 8
    t.string   "further_education_plans",    :limit => 500
    t.string   "spouse_further_education",   :limit => 500
    t.integer  "settle_else"
    t.integer  "sexual_preference",          :limit => 2,   :default => 0
    t.integer  "virginity_opinion"
    t.string   "ideal_marriage",             :limit => 500
    t.integer  "salary",                     :limit => 8
    t.string   "hobbies",                    :limit => 500
    t.integer  "siblings",                   :limit => 2
    t.string   "profession"
    t.string   "dream_for_future",           :limit => 500
    t.string   "interested_in",              :limit => 500
    t.string   "not_interested_in",          :limit => 500
    t.string   "settled_in"
    t.boolean  "dont_search",                               :default => false
    t.date     "hidden_since"
    t.datetime "created_at",                                                   :null => false
    t.datetime "updated_at",                                                   :null => false
    t.integer  "status",                     :limit => 1,   :default => 0
    t.date     "locked_since"
    t.integer  "locked_with"
    t.boolean  "email_verified",                            :default => false
    t.date     "notifying_for_success_date"
    t.date     "marriage_informed_date"
    t.date     "rejected_on"
    t.string   "email",                      :limit => 128,                    :null => false
    t.string   "auth_token"
    t.string   "password_reset_token"
    t.datetime "password_reset_sent_at"
    t.string   "password_digest"
    t.string   "short_bio",                  :limit => 500
    t.string   "education"
    t.string   "photo_url"
    t.string   "blog_url"
    t.integer  "age"
  end

  add_index "users", ["family_preference"], :name => "index_users_on_family_preference"
  add_index "users", ["interested_in"], :name => "index_users_on_interested_in", :length => {"interested_in"=>"255"}
  add_index "users", ["name"], :name => "index_users_on_name"
  add_index "users", ["profession"], :name => "index_users_on_profession"
  add_index "users", ["spouse_preference"], :name => "index_users_on_spouse_preference"

end
