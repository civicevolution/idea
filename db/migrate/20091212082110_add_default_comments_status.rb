class AddDefaultCommentsStatus < ActiveRecord::Migration
  def self.up
    change_column_default(:comments, :status, 'ok')
  end

  def self.down
    change_column_default(:comments, :status, nil)
  end
end
