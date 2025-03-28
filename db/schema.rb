# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_03_28_125121) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "appointment_services", force: :cascade do |t|
    t.bigint "appointment_id", null: false
    t.bigint "service_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["appointment_id"], name: "index_appointment_services_on_appointment_id"
    t.index ["service_id"], name: "index_appointment_services_on_service_id"
  end

  create_table "appointments", force: :cascade do |t|
    t.bigint "customer_id", null: false
    t.bigint "car_id", null: false
    t.date "date"
    t.time "time"
    t.string "status"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["car_id"], name: "index_appointments_on_car_id"
    t.index ["customer_id"], name: "index_appointments_on_customer_id"
  end

  create_table "appointments_services", force: :cascade do |t|
    t.bigint "appointment_id", null: false
    t.bigint "service_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["appointment_id"], name: "index_appointments_services_on_appointment_id"
    t.index ["service_id"], name: "index_appointments_services_on_service_id"
  end

  create_table "cars", force: :cascade do |t|
    t.bigint "customer_id", null: false
    t.string "make"
    t.string "model"
    t.integer "year"
    t.string "vin"
    t.string "license_plate"
    t.integer "initial_mileage"
    t.integer "current_mileage"
    t.string "customs_clearance_number"
    t.date "technical_visit_date"
    t.string "insurance_category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "average_daily_mileage"
    t.index ["customer_id"], name: "index_cars_on_customer_id"
    t.index ["vin"], name: "index_cars_on_vin"
  end

  create_table "customers", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "phone"
    t.text "address"
    t.bigint "user_id", null: false
    t.string "national_id"
    t.string "tax_number"
    t.string "region_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_customers_on_email"
    t.index ["user_id"], name: "index_customers_on_user_id"
  end

  create_table "mileage_records", force: :cascade do |t|
    t.bigint "car_id", null: false
    t.datetime "recorded_at"
    t.integer "mileage"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["car_id"], name: "index_mileage_records_on_car_id"
  end

  create_table "service_schedules", force: :cascade do |t|
    t.bigint "car_id", null: false
    t.string "service_type"
    t.integer "mileage_interval"
    t.integer "time_interval_months"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "predicted_next_service_date"
    t.date "next_service_date"
    t.integer "next_service_mileage"
    t.index ["car_id"], name: "index_service_schedules_on_car_id"
    t.index ["next_service_date"], name: "index_service_schedules_on_next_service_date"
    t.index ["next_service_mileage"], name: "index_service_schedules_on_next_service_mileage"
  end

  create_table "services", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.decimal "price"
    t.integer "duration"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "active"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_digest"
    t.string "role"
    t.string "name"
    t.boolean "is_superadmin"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email"
  end

  add_foreign_key "appointment_services", "appointments"
  add_foreign_key "appointment_services", "services"
  add_foreign_key "appointments", "cars"
  add_foreign_key "appointments", "customers"
  add_foreign_key "appointments_services", "appointments"
  add_foreign_key "appointments_services", "services"
  add_foreign_key "cars", "customers"
  add_foreign_key "customers", "users"
  add_foreign_key "mileage_records", "cars"
  add_foreign_key "service_schedules", "cars"
end
