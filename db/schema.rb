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

ActiveRecord::Schema.define(version: 20170502210020) do

  create_table "barcodes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.string   "code"
    t.integer  "item_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_barcodes_on_item_id", using: :btree
  end

  create_table "batches", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "item_id"
    t.integer  "user_id"
    t.integer  "count"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.integer  "price"
    t.integer  "locked_amount",  default: 0
    t.integer  "barcode_id"
    t.integer  "company_id"
    t.integer  "supplier_price"
    t.index ["barcode_id"], name: "index_batches_on_barcode_id", using: :btree
    t.index ["company_id"], name: "index_batches_on_company_id", using: :btree
    t.index ["item_id"], name: "index_batches_on_item_id", using: :btree
    t.index ["user_id"], name: "index_batches_on_user_id", using: :btree
  end

  create_table "companies", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name",                     collation: "utf8mb4_general_ci"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.integer  "user_id"
    t.boolean  "is_deleted"
    t.integer  "company_id"
    t.boolean  "have_weight"
    t.index ["company_id"], name: "index_items_on_company_id", using: :btree
    t.index ["user_id"], name: "index_items_on_user_id", using: :btree
  end

  create_table "positions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "item_id"
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "receipt_id"
    t.integer  "count",      default: 0
    t.integer  "batch_id"
    t.integer  "price"
    t.index ["batch_id"], name: "index_positions_on_batch_id", using: :btree
    t.index ["item_id"], name: "index_positions_on_item_id", using: :btree
    t.index ["receipt_id"], name: "index_positions_on_receipt_id", using: :btree
  end

  create_table "receipts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
    t.integer  "total"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "paid"
    t.integer  "user_id"
    t.integer  "status"
    t.integer  "company_id"
    t.index ["company_id"], name: "index_receipts_on_company_id", using: :btree
    t.index ["user_id"], name: "index_receipts_on_user_id", using: :btree
  end

  create_table "return_receipt_positions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "position_id"
    t.integer  "amount"
    t.integer  "return_receipt_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["position_id"], name: "index_return_receipt_positions_on_position_id", using: :btree
    t.index ["return_receipt_id"], name: "index_return_receipt_positions_on_return_receipt_id", using: :btree
  end

  create_table "return_receipts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "receipt_id"
    t.integer  "company_id"
    t.index ["company_id"], name: "index_return_receipts_on_company_id", using: :btree
    t.index ["receipt_id"], name: "index_return_receipts_on_receipt_id", using: :btree
    t.index ["user_id"], name: "index_return_receipts_on_user_id", using: :btree
  end

  create_table "roles", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name",                      null: false
    t.string   "title",                     null: false
    t.text     "description", limit: 65535, null: false
    t.text     "the_role",    limit: 65535, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1" do |t|
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
    t.string   "name"
    t.string   "company_name"
    t.integer  "role_id"
    t.integer  "company_id"
    t.index ["company_id"], name: "index_users_on_company_id", using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  create_table "write_offs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "batch_id"
    t.integer  "item_id"
    t.integer  "amount"
    t.integer  "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["batch_id"], name: "index_write_offs_on_batch_id", using: :btree
    t.index ["item_id"], name: "index_write_offs_on_item_id", using: :btree
  end

  add_foreign_key "barcodes", "items"
  add_foreign_key "batches", "barcodes"
  add_foreign_key "batches", "companies"
  add_foreign_key "batches", "items"
  add_foreign_key "batches", "users"
  add_foreign_key "items", "companies"
  add_foreign_key "items", "users"
  add_foreign_key "positions", "batches"
  add_foreign_key "positions", "items"
  add_foreign_key "positions", "receipts"
  add_foreign_key "receipts", "companies"
  add_foreign_key "receipts", "users"
  add_foreign_key "return_receipt_positions", "positions"
  add_foreign_key "return_receipt_positions", "return_receipts"
  add_foreign_key "return_receipts", "companies"
  add_foreign_key "return_receipts", "receipts"
  add_foreign_key "return_receipts", "users"
  add_foreign_key "users", "companies"
  add_foreign_key "write_offs", "batches"
  add_foreign_key "write_offs", "items"
end
