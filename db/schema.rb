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

ActiveRecord::Schema.define(version: 2019_06_20_163230) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

  create_table "dummy", id: false, force: :cascade do |t|
    t.string "name", limit: 100
    t.string "complaint", limit: 100
    t.string "descript", limit: 100
    t.string "boro", limit: 50
    t.float "lat"
    t.float "lon"
    t.geometry "geom", limit: {:srid=>4326, :type=>"st_point"}
  end

  create_table "dummy1", id: false, force: :cascade do |t|
    t.geometry "destination", limit: {:srid=>102689, :type=>"st_polygon"}
    t.datetime "created_at", default: -> { "now()" }
    t.datetime "modified_at", default: -> { "CURRENT_TIMESTAMP" }
  end

  create_table "partners", force: :cascade do |t|
    t.string "name"
    t.string "phone", null: false
    t.integer "status", default: 0
    t.geography "location", limit: {:srid=>4326, :type=>"st_point", :geographic=>true}
    t.geography "coverage", limit: {:srid=>4326, :type=>"st_polygon", :geographic=>true}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["coverage"], name: "index_partners_on_coverage", using: :gist
  end

  create_table "tasks", force: :cascade do |t|
    t.geometry "source", limit: {:srid=>0, :type=>"st_point"}, null: false
    t.geometry "destination", limit: {:srid=>0, :type=>"st_point"}, null: false
    t.integer "status", default: 0
    t.integer "partner_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["partner_id", "updated_at"], name: "partner_id_updated_at_composite_index", unique: true
  end

end
