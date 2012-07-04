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

ActiveRecord::Schema.define(:version => 20120704161622) do

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
