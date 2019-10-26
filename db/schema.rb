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

ActiveRecord::Schema.define(version: 20181109175040) do

  create_table "admins", force: :cascade do |t|
    t.string   "first"
    t.string   "last"
    t.string   "email"
    t.string   "password_digest"
    t.integer  "level"
    t.string   "reset_hash"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "clothiers", force: :cascade do |t|
    t.string   "first"
    t.string   "last"
    t.string   "email"
    t.string   "showroom"
    t.boolean  "active"
    t.string   "password_digest"
    t.string   "reset_hash"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "csv_codes", force: :cascade do |t|
    t.string   "garment"
    t.string   "code"
    t.string   "property"
    t.text     "values"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "property_codes", force: :cascade do |t|
    t.string   "code"
    t.text     "conditions"
    t.string   "garment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["garment"], name: "index_property_codes_on_garment"
  end

  create_table "settings", force: :cascade do |t|
    t.string   "showrooms"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "webhooks", force: :cascade do |t|
    t.text     "list"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
