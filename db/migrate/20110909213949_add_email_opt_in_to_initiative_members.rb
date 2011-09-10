class AddEmailOptInToInitiativeMembers < ActiveRecord::Migration
  def self.up
    add_column :initiative_members, :email_opt_in, :bool, :default => false
  end

  def self.down
    remove_column :initiative_members, :email_opt_in
  end
end
