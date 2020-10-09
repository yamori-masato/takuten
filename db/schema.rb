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

ActiveRecord::Schema.define(version: 2020_10_09_170725) do

  create_table "bands", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "has_regular", default: false, null: false
    t.index ["name"], name: "index_bands_on_name", unique: true
  end

  create_table "exception_times", force: :cascade do |t|
    t.integer "recurring_id", null: false
    t.date "date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recurring_id"], name: "index_exception_times_on_recurring_id"
  end

  create_table "recurrings", force: :cascade do |t|
    t.date "date_start", null: false
    t.date "date_end"
    t.time "time_start", null: false
    t.time "time_end", null: false
    t.integer "band_id"
    t.string "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["band_id"], name: "index_recurrings_on_band_id"
  end

  create_table "singles", force: :cascade do |t|
    t.date "date", null: false
    t.time "time_start", null: false
    t.time "time_end", null: false
    t.integer "band_id"
    t.string "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["band_id"], name: "index_singles_on_band_id"
  end

  create_table "timetables", force: :cascade do |t|
    t.date "date_start", null: false
    t.date "date_end"
    t.text "sections", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_bands", force: :cascade do |t|
    t.integer "user_id"
    t.integer "band_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["band_id"], name: "index_user_bands_on_band_id"
    t.index ["user_id"], name: "index_user_bands_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "nickname"
    t.string "password_digest", null: false
    t.string "token"
    t.boolean "admin", default: false, null: false
    t.integer "grade"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_users_on_name", unique: true
    t.index ["token"], name: "index_users_on_token", unique: true
  end

end
