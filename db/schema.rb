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

ActiveRecord::Schema.define(:version => 20120706192326) do

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
    t.string   "name",                     :limit => 50,                     :null => false
    t.date     "dob",                                                        :null => false
    t.string   "sex",                                                        :null => false
    t.integer  "family_preference",        :limit => 2
    t.float    "height"
    t.integer  "spouse_preference",        :limit => 2
    t.integer  "spouse_salary",            :limit => 8
    t.string   "further_education_plans",  :limit => 500
    t.string   "spouse_further_education", :limit => 500
    t.string   "settle_else",              :limit => 500
    t.integer  "sexual_preference",        :limit => 2,   :default => 0
    t.string   "virginity_opinion",        :limit => 500
    t.string   "ideal_marriage",           :limit => 500
    t.integer  "salary",                   :limit => 8
    t.string   "hobbies",                  :limit => 500
    t.integer  "siblings",                 :limit => 2
    t.integer  "profession",               :limit => 2
    t.string   "dream_for_future",         :limit => 500
    t.string   "interested_in",            :limit => 500
    t.string   "not_interested_in",        :limit => 500
    t.string   "settled_in"
    t.boolean  "dont_search",                             :default => false
    t.date     "hidden_since"
    t.datetime "created_at",                                                 :null => false
    t.datetime "updated_at",                                                 :null => false
  end

  add_index "users", ["family_preference"], :name => "index_users_on_family_preference"
  add_index "users", ["interested_in"], :name => "index_users_on_interested_in", :length => {"interested_in"=>"255"}
  add_index "users", ["name"], :name => "index_users_on_name"
  add_index "users", ["profession"], :name => "index_users_on_profession"
  add_index "users", ["spouse_preference"], :name => "index_users_on_spouse_preference"

end
