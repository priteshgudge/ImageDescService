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

ActiveRecord::Schema.define(:version => 20150217131403) do

  create_table "active_admin_comments", :force => true do |t|
    t.integer  "resource_id",   :null => false
    t.string   "resource_type", :null => false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], :name => "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], :name => "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], :name => "index_admin_notes_on_resource_type_and_resource_id"

  create_table "alts", :force => true do |t|
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.string   "alt",                                 :null => false
    t.integer  "submitter_id"
    t.integer  "dynamic_image_id"
    t.boolean  "from_source",      :default => false
  end

  add_index "alts", ["dynamic_image_id"], :name => "alts_dynamic_image_id"
  add_index "alts", ["submitter_id"], :name => "alts_submitter_id"

  create_table "audits", :force => true do |t|
    t.integer  "auditable_id"
    t.string   "auditable_type"
    t.integer  "associated_id"
    t.string   "associated_type"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "username"
    t.string   "action"
    t.text     "audited_changes"
    t.integer  "version",         :default => 0
    t.string   "comment"
    t.string   "remote_address"
    t.datetime "created_at"
  end

  add_index "audits", ["associated_id", "associated_type"], :name => "associated_index"
  add_index "audits", ["auditable_id", "auditable_type"], :name => "auditable_index"
  add_index "audits", ["created_at"], :name => "index_audits_on_created_at"
  add_index "audits", ["user_id", "user_type"], :name => "user_index"

  create_table "book_fragments", :force => true do |t|
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "book_id"
    t.integer  "sequence_number"
  end

  add_index "book_fragments", ["book_id"], :name => "book_fragments_book_id"

  create_table "book_stats", :force => true do |t|
    t.integer "total_images"
    t.integer "total_essential_images",                                     :default => 0
    t.integer "total_images_described",                                     :default => 0
    t.integer "essential_images_described",                                 :default => 0
    t.integer "book_id"
    t.integer "approved_descriptions",                                      :default => 0
    t.decimal "percent_essential_described", :precision => 10, :scale => 0, :default => 0
  end

  add_index "book_stats", ["book_id"], :name => "book_stats_book_id"

  create_table "books", :force => true do |t|
    t.string   "uid",                                              :null => false
    t.string   "title"
    t.string   "isbn",           :limit => 13
    t.integer  "status"
    t.datetime "created_at",                                       :null => false
    t.datetime "updated_at",                                       :null => false
    t.string   "xml_file",                     :default => "none", :null => false
    t.datetime "last_approved"
    t.integer  "library_id",                                       :null => false
    t.integer  "user_id"
    t.string   "publisher"
    t.date     "publisher_date"
    t.string   "file_type"
    t.string   "authors"
    t.string   "description"
    t.datetime "deleted_at"
  end

  add_index "books", ["isbn"], :name => "index_books_on_isbn"
  add_index "books", ["library_id"], :name => "books_library_id"
  add_index "books", ["title"], :name => "index_books_on_title"

  create_table "content_models", :force => true do |t|
    t.text     "summary"
    t.text     "long_desc",                                                :null => false
    t.text     "simplified_language_description"
    t.integer  "target_age_start"
    t.integer  "target_age_end"
    t.string   "target_grade_start"
    t.string   "target_grade_end"
    t.integer  "description_quality"
    t.string   "language",                        :default => "en-US",     :null => false
    t.string   "repository",                      :default => "Bookshare", :null => false
    t.string   "credentials"
    t.boolean  "is_current",                      :default => false,       :null => false
    t.string   "creator",                                                  :null => false
    t.datetime "date_approved"
    t.integer  "image_id",                                                 :null => false
    t.datetime "created_at",                                               :null => false
    t.datetime "updated_at",                                               :null => false
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.string   "queue"
  end

  create_table "descriptions", :force => true do |t|
    t.string   "description",   :limit => 16384,                          :null => false
    t.boolean  "is_current",                     :default => false,       :null => false
    t.string   "submitter",                      :default => "anonymous", :null => false
    t.datetime "date_approved"
    t.integer  "image_id",                                                :null => false
    t.datetime "created_at",                                              :null => false
    t.datetime "updated_at",                                              :null => false
  end

  create_table "dynamic_descriptions", :force => true do |t|
    t.string   "body",                            :limit => 16384,                          :null => false
    t.boolean  "is_current",                                       :default => false,       :null => false
    t.datetime "date_approved"
    t.integer  "dynamic_image_id",                                                          :null => false
    t.datetime "created_at",                                                                :null => false
    t.datetime "updated_at",                                                                :null => false
    t.integer  "book_id"
    t.text     "summary"
    t.text     "simplified_language_description"
    t.integer  "target_age_start"
    t.integer  "target_age_end"
    t.integer  "target_grade_start"
    t.integer  "target_grade_end"
    t.integer  "description_quality"
    t.string   "language",                                         :default => "en-US",     :null => false
    t.string   "repository",                                       :default => "Bookshare", :null => false
    t.string   "credentials"
    t.text     "annotation"
    t.string   "tactile_src"
    t.text     "tactile_tour"
    t.string   "simplified_image_src"
    t.text     "simplified_image_tour"
    t.integer  "submitter_id"
  end

  add_index "dynamic_descriptions", ["dynamic_image_id", "is_current"], :name => "dynamic_descriptions_uid_image_id_current"
  add_index "dynamic_descriptions", ["dynamic_image_id"], :name => "index_dynamic_descriptions_on_dynamic_image_id"
  add_index "dynamic_descriptions", ["submitter_id"], :name => "dynamic_descriptions_submitter_id"

  create_table "dynamic_images", :force => true do |t|
    t.string   "image_location"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.boolean  "should_be_described"
    t.integer  "width"
    t.integer  "height"
    t.string   "xml_id"
    t.integer  "book_id"
    t.string   "physical_file_file_name"
    t.string   "physical_file_content_type"
    t.integer  "physical_file_file_size"
    t.datetime "physical_file_updated_at"
    t.integer  "book_fragment_id"
    t.integer  "image_category_id"
  end

  add_index "dynamic_images", ["book_fragment_id"], :name => "dynamic_images_book_frag_id"
  add_index "dynamic_images", ["book_id", "image_location"], :name => "index_dynamic_images_on_book_id_and_image_location"
  add_index "dynamic_images", ["image_location"], :name => "index_dynamic_images_on_book_uid_and_image_location"
  add_index "dynamic_images", ["should_be_described"], :name => "index_dynamic_images_on_book_uid_and_should_be_described"

  create_table "image_categories", :force => true do |t|
    t.string   "name",             :null => false
    t.string   "sample_file_name"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "order_to_display"
  end

  create_table "images", :force => true do |t|
    t.integer  "book_id",                         :null => false
    t.string   "image_id",                        :null => false
    t.string   "isbn",            :limit => 13
    t.integer  "page_number"
    t.integer  "sequence_number"
    t.string   "caption",         :limit => 8192
    t.string   "url"
    t.integer  "library_id"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  create_table "jobs", :force => true do |t|
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
    t.string   "state",             :default => "new", :null => false
    t.string   "job_type"
    t.integer  "user_id"
    t.text     "enter_params"
    t.text     "exit_params"
    t.string   "error_explanation"
  end

  add_index "jobs", ["user_id"], :name => "jobs_user_id"

  create_table "libraries", :force => true do |t|
    t.string   "name",       :limit => 128, :null => false
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "libraries", ["name"], :name => "idx_library_name_unique", :unique => true

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "subject_expertises", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "user_libraries", :force => true do |t|
    t.integer  "user_id"
    t.integer  "library_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "user_libraries", ["library_id"], :name => "user_libraries_library_id"
  add_index "user_libraries", ["user_id"], :name => "user_libraries_user_id"

  create_table "user_roles", :force => true do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "user_roles", ["role_id"], :name => "user_roles_role_id"
  add_index "user_roles", ["user_id"], :name => "user_roles_user_id"

  create_table "user_subject_expertises", :force => true do |t|
    t.integer  "user_id"
    t.integer  "subject_expertise_id"
    t.datetime "created_at",           :null => false
    t.datetime "updated_at",           :null => false
  end

  add_index "user_subject_expertises", ["subject_expertise_id"], :name => "user_subject_expertises_subject_expertise_id"
  add_index "user_subject_expertises", ["user_id"], :name => "user_subject_expertises_user_id"

  create_table "users", :force => true do |t|
    t.string   "email",                   :default => "",    :null => false
    t.string   "encrypted_password",      :default => "",    :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",           :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
    t.string   "username",                                   :null => false
    t.string   "first_name"
    t.string   "last_name"
    t.string   "other_subject_expertise"
    t.boolean  "agreed_tos",              :default => false
    t.datetime "deleted_at"
  end

  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
