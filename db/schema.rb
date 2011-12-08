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

ActiveRecord::Schema.define(:version => 20111206173029) do

  create_table "activities", :force => true do |t|
    t.integer  "member_id"
    t.integer  "team_id"
    t.string   "action"
    t.text     "cookie"
    t.text     "user_agent"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ip",         :limit => nil
  end

  create_table "admin_groups", :force => true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "admin_privileges", :force => true do |t|
    t.integer  "admin_group_id"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "admins", :force => true do |t|
    t.integer  "member_id"
    t.integer  "admin_group_id"
    t.integer  "initiative_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "answer_diffs", :force => true do |t|
    t.integer  "answer_id"
    t.integer  "member_id"
    t.integer  "version"
    t.binary   "diff"
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "answer_ratings", :force => true do |t|
    t.integer  "answer_id",                 :null => false
    t.integer  "member_id",                 :null => false
    t.integer  "rating",     :default => 0, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "answers", :force => true do |t|
    t.integer  "member_id",                         :null => false
    t.boolean  "anonymous",      :default => false, :null => false
    t.string   "status",         :default => "ok",  :null => false
    t.text     "text",                              :null => false
    t.integer  "ver",            :default => 0,     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "team_id",        :default => 0,     :null => false
    t.integer  "question_id",    :default => 0,     :null => false
    t.integer  "lock_member_id"
  end

  create_table "bs_idea_favorite_priorities", :force => true do |t|
    t.integer  "question_id"
    t.integer  "member_id"
    t.string   "priority",    :limit => nil
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bs_idea_favorites", :force => true do |t|
    t.integer  "bs_idea_id"
    t.integer  "member_id"
    t.boolean  "favorite"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bs_idea_ratings", :force => true do |t|
    t.integer  "idea_id"
    t.integer  "member_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "rating",     :default => 0
  end

  create_table "bs_ideas", :force => true do |t|
    t.integer  "question_id"
    t.integer  "member_id"
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "team_id"
    t.boolean  "publish"
  end

  create_table "call_to_action_emails", :force => true do |t|
    t.string   "scenario"
    t.integer  "version"
    t.string   "subject"
    t.text     "message"
    t.string   "data"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "call_to_action_emails_sents", :force => true do |t|
    t.integer  "member_id"
    t.integer  "member_lookup_code_id"
    t.text     "scenario"
    t.integer  "version"
    t.integer  "team_id"
    t.datetime "opened_email"
    t.datetime "visit_site"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "call_to_action_queues", :force => true do |t|
    t.integer  "team_id",    :default => 0,     :null => false
    t.integer  "member_id",                     :null => false
    t.boolean  "sent",       :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "scenario"
  end

  add_index "call_to_action_queues", ["member_id", "team_id"], :name => "cta_unique_member_id_team_id", :unique => true

  create_table "chat_active_sessions", :force => true do |t|
    t.integer  "chat_session_id", :null => false
    t.integer  "team_id",         :null => false
    t.string   "status",          :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "item_id",         :null => false
    t.integer  "list_id",         :null => false
  end

  create_table "chat_messages", :force => true do |t|
    t.integer  "chat_session_id", :null => false
    t.integer  "member_id",       :null => false
    t.text     "text",            :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "chat_sessions", :force => true do |t|
    t.string   "status",     :default => "ok", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "check_list_items", :force => true do |t|
    t.integer  "team_id",                            :null => false
    t.string   "title",                              :null => false
    t.text     "description"
    t.integer  "par_id",                             :null => false
    t.integer  "order",                              :null => false
    t.boolean  "completed",       :default => false
    t.boolean  "request_details", :default => false
    t.text     "details"
    t.integer  "discussion",      :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "client_details", :force => true do |t|
    t.string   "session_id"
    t.string   "ip",         :limit => nil
    t.integer  "member_id"
    t.integer  "team_id"
    t.string   "url"
    t.text     "user_agent"
    t.text     "error_log"
    t.integer  "load_time"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "client_load_times", :force => true do |t|
    t.string   "ip",         :limit => nil
    t.string   "session_id"
    t.integer  "team_id"
    t.integer  "member_id"
    t.integer  "page_load"
    t.integer  "ape_load"
    t.integer  "all_init"
    t.text     "user_agent"
    t.integer  "height"
    t.integer  "width"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "com_ratings", :force => true do |t|
    t.integer  "comment_id"
    t.integer  "member_id"
    t.integer  "up"
    t.integer  "down"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "comments", :force => true do |t|
    t.integer  "member_id",                      :null => false
    t.boolean  "anonymous",   :default => false, :null => false
    t.string   "status",      :default => "ok",  :null => false
    t.text     "text",                           :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "team_id"
    t.boolean  "publish"
    t.integer  "parent_type"
    t.integer  "parent_id"
  end

  create_table "content_reports", :force => true do |t|
    t.integer  "item_id"
    t.integer  "member_id"
    t.string   "sender_name"
    t.string   "sender_email"
    t.string   "report_type"
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "content_type"
    t.integer  "content_id"
  end

  create_table "default_answers", :force => true do |t|
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "checklist"
    t.text     "extended_checklist"
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
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "email_lookup_codes", :force => true do |t|
    t.string   "code"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "email_lookup_codes", ["code"], :name => "unique_email_lookup_code", :unique => true

  create_table "endorsements", :force => true do |t|
    t.integer  "team_id"
    t.integer  "member_id"
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "form_items", :force => true do |t|
    t.integer  "form_id",    :null => false
    t.string   "name",       :null => false
    t.text     "value",      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "forms", :force => true do |t|
    t.integer  "member_id",  :null => false
    t.string   "form_name",  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "general_email_settings", :force => true do |t|
    t.integer  "member_id",                                    :null => false
    t.boolean  "accept_broadcast_messages", :default => false
    t.boolean  "forward_messages",          :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "general_email_settings", ["member_id"], :name => "unique_general_email_settings_member_id", :unique => true

  create_table "help_requests", :force => true do |t|
    t.integer  "client_details_id", :null => false
    t.string   "name"
    t.string   "email"
    t.integer  "category",          :null => false
    t.text     "message",           :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "initiative_members", :force => true do |t|
    t.integer  "initiative_id",                      :null => false
    t.integer  "member_id",                          :null => false
    t.boolean  "accept_tos",                         :null => false
    t.integer  "member_category",                    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "email_opt_in",    :default => false
  end

  create_table "initiative_restrictions", :force => true do |t|
    t.integer  "initiative_id",                    :null => false
    t.string   "action",                           :null => false
    t.string   "restriction",                      :null => false
    t.string   "arg",                              :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "mandatory",     :default => false
  end

  create_table "initiatives", :force => true do |t|
    t.string   "title",                                                          :null => false
    t.text     "description",                                                    :null => false
    t.integer  "min_members",                  :default => 1,                    :null => false
    t.integer  "max_members",                  :default => 25,                   :null => false
    t.integer  "max_teams_per_member",         :default => 1000,                 :null => false
    t.boolean  "limit_access"
    t.string   "access_code"
    t.boolean  "can_propose_team",             :default => true
    t.boolean  "prescreen_proposals",          :default => false
    t.string   "timezone"
    t.string   "lang",                         :default => "us"
    t.integer  "config_id"
    t.boolean  "public_face"
    t.integer  "public_face_rating_threshold", :default => 3
    t.string   "join_test"
    t.boolean  "approve_join"
    t.boolean  "send_invites"
    t.boolean  "approve_invites"
    t.string   "admin_groups"
    t.string   "country"
    t.string   "state"
    t.string   "county"
    t.string   "city"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "domain",                       :default => "civicevolution.org", :null => false
  end

  create_table "invites", :force => true do |t|
    t.integer  "member_id"
    t.integer  "initiative_id"
    t.integer  "team_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "_ilc"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "item_diffs", :force => true do |t|
    t.integer  "o_id",       :null => false
    t.integer  "o_type",     :null => false
    t.integer  "ver",        :null => false
    t.integer  "member_id",  :null => false
    t.boolean  "anonymous",  :null => false
    t.binary   "diff",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "item_locks", :force => true do |t|
    t.integer  "o_id",       :null => false
    t.integer  "o_type",     :null => false
    t.integer  "member_id",  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "item_types", :force => true do |t|
    t.string   "type"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "item_versions", :force => true do |t|
    t.integer  "item_id"
    t.integer  "item_type"
    t.integer  "ver"
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "items", :force => true do |t|
    t.integer  "team_id",                                   :null => false
    t.integer  "o_id",                                      :null => false
    t.integer  "o_type",                                    :null => false
    t.integer  "par_id",                                    :null => false
    t.integer  "order",                                     :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sib_id",                     :default => 0, :null => false
    t.string   "ancestors",   :limit => nil
    t.integer  "target_id",                  :default => 0
    t.integer  "target_type",                :default => 0
  end

  create_table "list_items", :force => true do |t|
    t.integer  "list_id"
    t.integer  "order"
    t.integer  "member_id"
    t.boolean  "anonymous",  :default => false
    t.text     "text"
    t.integer  "ver"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "deleted",    :default => false
  end

  create_table "lists", :force => true do |t|
    t.integer  "format",     :default => 1
    t.boolean  "anonymous",  :default => true
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "title",                        :null => false
    t.text     "text",                         :null => false
    t.integer  "member_id",                    :null => false
  end

  create_table "live_conclusions", :force => true do |t|
    t.integer  "live_session_id"
    t.integer  "themer_id"
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "live_events", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "live_nodes", :force => true do |t|
    t.integer  "live_event_id"
    t.string   "name"
    t.text     "description"
    t.integer  "parent_id"
    t.string   "username"
    t.string   "password"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "role"
  end

  create_table "live_sessions", :force => true do |t|
    t.integer  "live_event_id"
    t.text     "name"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "order_id"
  end

  create_table "live_talking_points", :force => true do |t|
    t.integer  "live_session_id"
    t.integer  "group_id"
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "live_themes", :force => true do |t|
    t.integer  "live_session_id"
    t.integer  "themer_id"
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "member_lookup_code_logs", :force => true do |t|
    t.string   "code",       :limit => nil
    t.integer  "member_id"
    t.string   "scenario"
    t.integer  "target_id"
    t.string   "target_url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "member_lookup_codes", :force => true do |t|
    t.string   "code",       :null => false
    t.integer  "member_id",  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "scenario"
  end

  add_index "member_lookup_codes", ["code"], :name => "unique_member_lookup_codes_code", :unique => true

  create_table "members", :force => true do |t|
    t.string   "email",                                                :null => false
    t.string   "first_name",                                           :null => false
    t.string   "last_name",                                            :null => false
    t.integer  "pic_id",                                               :null => false
    t.integer  "init_id",                                              :null => false
    t.string   "hashed_pwd"
    t.boolean  "confirmed",                         :default => false
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.string   "location"
    t.string   "access_code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "salt"
    t.string   "ape_code",           :limit => 14
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.string   "ip",                 :limit => nil
    t.boolean  "email_ok",                          :default => true
  end

  add_index "members", ["ape_code"], :name => "unique_members_ape_code", :unique => true

  create_table "notification_requests", :force => true do |t|
    t.integer  "team_id"
    t.integer  "member_id"
    t.integer  "report_type"
    t.integer  "report_format"
    t.boolean  "immediate"
    t.string   "dow_to_run",     :limit => nil
    t.string   "hour_to_run",    :limit => nil
    t.string   "match_queue",    :limit => nil
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "sent_time"
    t.boolean  "call_to_action"
  end

  create_table "page_chat_messages", :force => true do |t|
    t.integer  "page_id"
    t.integer  "member_id"
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pages", :force => true do |t|
    t.string   "page_title"
    t.text     "html"
    t.integer  "chat_par_id"
    t.string   "chat_title"
    t.boolean  "discussion"
    t.string   "classname"
    t.string   "css"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "nav_title"
  end

  create_table "participant_stats", :force => true do |t|
    t.integer  "member_id"
    t.integer  "team_id"
    t.integer  "proposal_views",            :default => 0
    t.integer  "question_views",            :default => 0
    t.integer  "friend_invites",            :default => 0
    t.integer  "following",                 :default => 0
    t.boolean  "endorse",                   :default => false
    t.integer  "talking_points",            :default => 0
    t.integer  "talking_point_edits",       :default => 0
    t.integer  "talking_point_ratings",     :default => 0
    t.integer  "talking_point_preferences", :default => 0
    t.integer  "comments",                  :default => 0
    t.integer  "content_reports",           :default => 0
    t.integer  "points_total",              :default => 0
    t.integer  "points_days1",              :default => 0
    t.integer  "points_days3",              :default => 0
    t.integer  "points_days7",              :default => 0
    t.integer  "points_days14",             :default => 0
    t.integer  "points_days28",             :default => 0
    t.integer  "points_days90",             :default => 0
    t.datetime "last_visit"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "level",                     :default => 1
    t.integer  "day_visits",                :default => 1
    t.datetime "last_day_visit"
    t.datetime "next_day_visit"
  end

  create_table "participation_event_details", :force => true do |t|
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "participation_events", :force => true do |t|
    t.integer  "initiative_id"
    t.integer  "team_id"
    t.integer  "question_id"
    t.integer  "item_type"
    t.integer  "item_id"
    t.integer  "member_id"
    t.integer  "event_id"
    t.integer  "points"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "preliminary_participant_activities", :force => true do |t|
    t.string   "email"
    t.text     "flash_params"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "init_id"
  end

  create_table "proposal_ideas", :force => true do |t|
    t.integer  "initiative_id",                        :null => false
    t.integer  "member_id",                            :null => false
    t.boolean  "accept_guidelines",                    :null => false
    t.text     "title",                                :null => false
    t.text     "text",                                 :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "launched",          :default => false, :null => false
  end

  create_table "proposal_stats", :force => true do |t|
    t.integer  "team_id"
    t.integer  "proposal_views",            :default => 0
    t.integer  "question_views",            :default => 0
    t.integer  "participants",              :default => 0
    t.integer  "friend_invites",            :default => 0
    t.integer  "followers",                 :default => 0
    t.integer  "endorsements",              :default => 0
    t.integer  "talking_points",            :default => 0
    t.integer  "talking_point_edits",       :default => 0
    t.integer  "talking_point_ratings",     :default => 0
    t.integer  "talking_point_preferences", :default => 0
    t.integer  "comments",                  :default => 0
    t.integer  "content_reports",           :default => 0
    t.integer  "proposal_views_base",       :default => 0
    t.integer  "question_views_base",       :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "points_total",              :default => 0
    t.integer  "points_days1",              :default => 0
    t.integer  "points_days3",              :default => 0
    t.integer  "points_days7",              :default => 0
    t.integer  "points_days14",             :default => 0
    t.integer  "points_days28",             :default => 0
    t.integer  "points_days90",             :default => 0
  end

  create_table "proposal_submits", :force => true do |t|
    t.integer  "team_id"
    t.integer  "member_id"
    t.string   "submit_type"
    t.string   "name"
    t.string   "email"
    t.string   "phone"
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "questions", :force => true do |t|
    t.integer  "member_id",                                        :null => false
    t.string   "status",                    :default => "ok",      :null => false
    t.text     "text",                                             :null => false
    t.integer  "num_answers",               :default => 1000,      :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "anonymous",                 :default => false,     :null => false
    t.integer  "ver",                       :default => 0,         :null => false
    t.string   "idea_criteria",             :default => "5..1000"
    t.string   "answer_criteria",           :default => "5..1500"
    t.integer  "default_answer_id"
    t.integer  "team_id"
    t.integer  "order_id"
    t.string   "talking_point_criteria"
    t.string   "talking_point_preferences"
    t.boolean  "inactive",                  :default => false
    t.string   "curated_tp_ids"
    t.boolean  "auto_curated",              :default => true
  end

  create_table "ratings", :force => true do |t|
    t.integer  "item_id",                                  :null => false
    t.integer  "member_id",                                :null => false
    t.decimal  "rating",     :precision => 3, :scale => 1, :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ratings", ["item_id", "member_id"], :name => "unique_item_id_member_id", :unique => true

  create_table "resources", :force => true do |t|
    t.integer  "comment_id"
    t.integer  "member_id"
    t.string   "title"
    t.text     "description"
    t.text     "link_url"
    t.string   "resource_file_name"
    t.integer  "resource_file_size"
    t.string   "resource_content_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "talking_point_acceptable_ratings", :force => true do |t|
    t.integer  "talking_point_id"
    t.integer  "member_id"
    t.integer  "rating"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "talking_point_preferences", :force => true do |t|
    t.integer  "talking_point_id"
    t.integer  "member_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "talking_point_versions", :force => true do |t|
    t.integer  "talking_point_id"
    t.integer  "member_id"
    t.integer  "version"
    t.string   "text"
    t.integer  "lock_member_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "talking_points", :force => true do |t|
    t.integer  "question_id"
    t.integer  "member_id"
    t.integer  "version"
    t.string   "text"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "order_id",    :default => 0
    t.boolean  "visible",     :default => true
  end

  create_table "team_content_logs", :force => true do |t|
    t.integer  "team_id"
    t.integer  "member_id"
    t.integer  "o_type"
    t.integer  "o_id"
    t.integer  "par_member_id"
    t.boolean  "processed"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "team_member_roles", :force => true do |t|
    t.integer  "team_id"
    t.integer  "member_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "team_member_roles", ["member_id", "role_id", "team_id"], :name => "tma_unique_member_id_role_id_team_id", :unique => true

  create_table "team_registrations", :force => true do |t|
    t.integer  "team_id",                            :null => false
    t.integer  "member_id",                          :null => false
    t.string   "status",                             :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "access_details", :default => "full"
  end

  create_table "teams", :force => true do |t|
    t.integer  "initiative_id",                                       :null => false
    t.integer  "org_id",                                              :null => false
    t.string   "title",                                               :null => false
    t.text     "problem_statement",                                   :null => false
    t.text     "solution_statement",                                  :null => false
    t.string   "status"
    t.integer  "min_members"
    t.integer  "max_members"
    t.string   "timezone"
    t.string   "lang"
    t.integer  "config_id"
    t.boolean  "public_face"
    t.integer  "public_face_rating_threshold"
    t.boolean  "archived"
    t.string   "signup_mode"
    t.string   "join_test"
    t.string   "join_code"
    t.boolean  "approve_join"
    t.boolean  "send_invites"
    t.boolean  "approve_invites"
    t.string   "admin_groups"
    t.string   "country"
    t.string   "state"
    t.string   "county"
    t.string   "city"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "com_criteria",                 :default => "5..1500"
    t.string   "res_criteria",                 :default => "5..500"
    t.boolean  "launched",                     :default => false,     :null => false
  end

  create_table "thumbs_ratings", :force => true do |t|
    t.integer  "item_id"
    t.integer  "member_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "up",         :default => 0
    t.integer  "down",       :default => 0
  end

  add_index "thumbs_ratings", ["item_id", "member_id"], :name => "unique_thumbs_ratings_item_id_member_id", :unique => true

end
