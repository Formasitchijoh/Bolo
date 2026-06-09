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

ActiveRecord::Schema[8.1].define(version: 2026_06_05_102133) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "addresses", force: :cascade do |t|
    t.bigint "addressable_id", null: false
    t.string "addressable_type", null: false
    t.datetime "created_at", null: false
    t.decimal "latitude", precision: 10, scale: 6, null: false
    t.decimal "longitude", precision: 10, scale: 6, null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["addressable_type", "addressable_id"], name: "index_addresses_on_addressable"
  end

  create_table "assignments", force: :cascade do |t|
    t.datetime "assigned_at"
    t.datetime "claim_window", null: false
    t.bigint "company_id"
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.datetime "rejected_at"
    t.string "status", null: false
    t.bigint "technician_id", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_assignments_on_company_id"
    t.index ["job_id"], name: "index_assignments_on_job_id"
    t.index ["technician_id"], name: "index_assignments_on_technician_id"
  end

  create_table "comments", force: :cascade do |t|
    t.text "body", null: false
    t.bigint "commentable_id", null: false
    t.string "commentable_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "companies", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "name", null: false
    t.string "status", null: false
    t.bigint "tenant_id", null: false
    t.datetime "updated_at", null: false
    t.index ["tenant_id"], name: "index_companies_on_tenant_id"
  end

  create_table "contacts", force: :cascade do |t|
    t.bigint "contactable_id", null: false
    t.string "contactable_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contactable_type", "contactable_id"], name: "index_contacts_on_contactable"
  end

  create_table "customers", force: :cascade do |t|
    t.integer "cancellation_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.string "status", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_customers_on_user_id"
  end

  create_table "job_categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_job_categories_on_name", unique: true
  end

  create_table "jobs", force: :cascade do |t|
    t.string "address"
    t.bigint "company_id"
    t.datetime "created_at", null: false
    t.bigint "customer_id", null: false
    t.text "details", null: false
    t.bigint "job_category_id", null: false
    t.decimal "latitude", precision: 10, scale: 6, null: false
    t.decimal "longitude", precision: 10, scale: 6, null: false
    t.jsonb "media", default: []
    t.decimal "price_range_max", precision: 10, scale: 2, null: false
    t.decimal "price_range_min", precision: 10, scale: 2, null: false
    t.integer "rebroadcast_count", default: 0, null: false
    t.string "status", default: "available"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_jobs_on_company_id"
    t.index ["customer_id"], name: "index_jobs_on_customer_id"
    t.index ["job_category_id"], name: "index_jobs_on_job_category_id"
  end

  create_table "line_items", force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.text "description", null: false
    t.datetime "updated_at", null: false
    t.bigint "work_order_id", null: false
    t.index ["work_order_id"], name: "index_line_items_on_work_order_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "details", null: false
    t.bigint "notifiable_id", null: false
    t.string "notifiable_type", null: false
    t.datetime "read_at"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "payments", force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.bigint "customer_id", null: false
    t.datetime "paid_at"
    t.string "payment_method", null: false
    t.decimal "platform_fee", precision: 10, scale: 2, null: false
    t.string "reference_id", null: false
    t.string "status", null: false
    t.decimal "tax", precision: 10, scale: 2, null: false
    t.datetime "updated_at", null: false
    t.bigint "work_order_id", null: false
    t.index ["customer_id"], name: "index_payments_on_customer_id"
    t.index ["work_order_id"], name: "index_payments_on_work_order_id"
  end

  create_table "phone_numbers", force: :cascade do |t|
    t.bigint "contact_id", null: false
    t.datetime "created_at", null: false
    t.string "number", null: false
    t.string "operator", null: false
    t.datetime "updated_at", null: false
    t.index ["contact_id"], name: "index_phone_numbers_on_contact_id"
  end

  create_table "quotes", force: :cascade do |t|
    t.datetime "approved_at"
    t.datetime "created_at", null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.string "status", null: false
    t.bigint "technician_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "work_order_id", null: false
    t.index ["technician_id"], name: "index_quotes_on_technician_id"
    t.index ["work_order_id"], name: "index_quotes_on_work_order_id"
  end

  create_table "ratings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "customer_id", null: false
    t.text "note"
    t.integer "star", null: false
    t.bigint "technician_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "work_order_id", null: false
    t.index ["customer_id"], name: "index_ratings_on_customer_id"
    t.index ["technician_id"], name: "index_ratings_on_technician_id"
    t.index ["work_order_id"], name: "index_ratings_on_work_order_id"
    t.check_constraint "star >= 1 AND star <= 5", name: "valid_star_range"
  end

  create_table "service_territories", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_service_territories_on_company_id"
  end

  create_table "shifts", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.datetime "end_time", null: false
    t.datetime "start_time", null: false
    t.bigint "technician_id", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_shifts_on_company_id"
    t.index ["technician_id", "start_time", "end_time"], name: "index_shifts_on_technician_id_and_start_time_and_end_time"
    t.index ["technician_id"], name: "index_shifts_on_technician_id"
  end

  create_table "skills", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_category_id", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["job_category_id"], name: "index_skills_on_job_category_id"
    t.index ["name"], name: "index_skills_on_name", unique: true
  end

  create_table "technician_companies", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.string "status", null: false
    t.bigint "technician_id", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_technician_companies_on_company_id"
    t.index ["technician_id"], name: "index_technician_companies_on_technician_id"
  end

  create_table "technician_skills", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "skill_id", null: false
    t.bigint "technician_id", null: false
    t.datetime "updated_at", null: false
    t.index ["skill_id"], name: "index_technician_skills_on_skill_id"
    t.index ["technician_id"], name: "index_technician_skills_on_technician_id"
  end

  create_table "technicians", force: :cascade do |t|
    t.decimal "average_rating", default: "0.0", null: false
    t.bigint "company_id"
    t.datetime "created_at", null: false
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.string "status", null: false
    t.datetime "suspended_until"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.boolean "verified", default: false, null: false
    t.index ["company_id"], name: "index_technicians_on_company_id"
    t.index ["user_id"], name: "index_technicians_on_user_id"
  end

  create_table "tenants", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_tenants_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "password_digest", null: false
    t.string "role", null: false
    t.string "status", default: "active", null: false
    t.datetime "suspended_until", precision: nil
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "work_orders", force: :cascade do |t|
    t.bigint "assignment_id", null: false
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.integer "estimated_time"
    t.jsonb "media", default: []
    t.text "notes"
    t.datetime "started_at"
    t.string "status", null: false
    t.datetime "updated_at", null: false
    t.index ["assignment_id"], name: "index_work_orders_on_assignment_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "assignments", "companies"
  add_foreign_key "assignments", "jobs"
  add_foreign_key "assignments", "technicians"
  add_foreign_key "comments", "users"
  add_foreign_key "companies", "tenants"
  add_foreign_key "customers", "users"
  add_foreign_key "jobs", "customers"
  add_foreign_key "jobs", "job_categories"
  add_foreign_key "line_items", "work_orders"
  add_foreign_key "notifications", "users"
  add_foreign_key "payments", "customers"
  add_foreign_key "payments", "work_orders"
  add_foreign_key "phone_numbers", "contacts"
  add_foreign_key "quotes", "technicians"
  add_foreign_key "quotes", "work_orders"
  add_foreign_key "ratings", "customers"
  add_foreign_key "ratings", "technicians"
  add_foreign_key "ratings", "work_orders"
  add_foreign_key "service_territories", "companies"
  add_foreign_key "shifts", "companies"
  add_foreign_key "shifts", "technicians"
  add_foreign_key "skills", "job_categories"
  add_foreign_key "technician_companies", "companies"
  add_foreign_key "technician_companies", "technicians"
  add_foreign_key "technician_skills", "skills"
  add_foreign_key "technician_skills", "technicians"
  add_foreign_key "technicians", "companies"
  add_foreign_key "technicians", "users"
  add_foreign_key "tenants", "users"
  add_foreign_key "work_orders", "assignments"
end
