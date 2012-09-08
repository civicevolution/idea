class CreateIdeaVersions < ActiveRecord::Migration
  def change
    create_table :idea_versions do |t|
      t.integer :idea_id
      t.integer :member_id
      t.text :text
      t.integer :version
      t.integer :lock_member_id

      t.timestamps
    end
  end
end
