class AddLevelsToParticipantStats < ActiveRecord::Migration
  def self.up
    add_column :participant_stats, :level, :integer, :default => 1
    add_column :participant_stats, :day_visits, :integer, :default => 1
    add_column :participant_stats, :last_day_visit, :timestamp
    add_column :participant_stats, :next_day_visit, :timestamp
    
    execute 'alter table participant_stats alter column last_day_visit set default now()'
    execute 'alter table participant_stats alter column next_day_visit set default now()'
    
    ParticipantStats.update_all("level = 1, day_visits = 1, last_day_visit = now(), next_day_visit = now()")
  end

  def self.down
    remove_column :participant_stats, :next_day_visit
    remove_column :participant_stats, :last_day_visit
    remove_column :participant_stats, :day_visits
    remove_column :participant_stats, :level
  end
end
