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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170207133819) do

  create_table "agreement_letters", force: :cascade do |t|
    t.integer  "user_id",    null: false
    t.integer  "event_id",   null: false
    t.string   "path",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "agreement_letters", ["event_id"], name: "index_agreement_letters_on_event_id"
  add_index "agreement_letters", ["user_id"], name: "index_agreement_letters_on_user_id"

  create_table "application_letters", force: :cascade do |t|
    t.string   "motivation"
    t.integer  "user_id",                                   null: false
    t.integer  "event_id",                                  null: false
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
    t.integer  "status",                    default: 2,     null: false
    t.string   "emergency_number"
    t.boolean  "vegetarian"
    t.boolean  "vegan"
    t.string   "allergies"
    t.text     "custom_application_fields"
    t.text     "annotation"
    t.string   "organisation"
    t.boolean  "status_notification_sent",  default: false, null: false
  end

  add_index "application_letters", ["event_id"], name: "index_application_letters_on_event_id"
  add_index "application_letters", ["user_id"], name: "index_application_letters_on_user_id"

  create_table "application_notes", force: :cascade do |t|
    t.text     "note"
    t.integer  "application_letter_id"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "application_notes", ["application_letter_id"], name: "index_application_notes_on_application_letter_id"

  create_table "date_ranges", force: :cascade do |t|
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "event_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "date_ranges", ["event_id"], name: "index_date_ranges_on_event_id"

  create_table "email_templates", force: :cascade do |t|
    t.integer "status"
    t.string  "subject"
    t.text    "content"
    t.boolean "hide_recipients"
  end

  create_table "events", force: :cascade do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "max_participants"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.boolean  "published",                  default: false
    t.string   "organizer"
    t.string   "knowledge_level"
    t.date     "application_deadline"
    t.text     "custom_application_fields"
    t.boolean  "hidden",                     default: false
    t.string   "image"
    t.boolean  "rejections_have_been_sent",  default: false
    t.boolean  "acceptances_have_been_sent", default: false
    t.string   "custom_image"
  end

  create_table "participant_groups", force: :cascade do |t|
    t.integer "user_id"
    t.integer "event_id"
    t.integer "group",    null: false
  end

  add_index "participant_groups", ["event_id"], name: "index_participant_groups_on_event_id"
  add_index "participant_groups", ["user_id"], name: "index_participant_groups_on_user_id"

  create_table "profiles", force: :cascade do |t|
    t.integer  "user_id",           null: false
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "gender"
    t.date     "birth_date"
    t.string   "street_name"
    t.string   "zip_code"
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.text     "discovery_of_site"
  end

  add_index "profiles", ["user_id"], name: "index_profiles_on_user_id"

  create_table "requests", force: :cascade do |t|
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
    t.integer  "form_of_address"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone_number"
    t.string   "street"
    t.string   "email"
    t.text     "topic_of_workshop"
    t.text     "time_period"
    t.integer  "number_of_participants"
    t.string   "knowledge_level"
    t.text     "annotations"
    t.integer  "status",                 default: 0
    t.string   "zip_code_city"
    t.string   "contact_person"
    t.text     "notes"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "role"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
