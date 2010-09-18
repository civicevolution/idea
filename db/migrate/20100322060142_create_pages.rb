class CreatePages < ActiveRecord::Migration
  def self.up
    create_table :pages do |t|
      t.string :page_title
      t.text :html
      t.integer :chat_par_id
      t.string :chat_title
      t.boolean :discussion
      t.string :classname
      t.string :css
    
      t.timestamps
    end
  end

  def self.down
    drop_table :pages
  end
end
