class ParticipantStats < ActiveRecord::Base
  belongs_to :member
  
  attr_accessible :member_id, :team_id, :proposal_views, :question_views, :friend_invites, :following, :endorse, :talking_points, :talking_point_edits, :talking_point_ratings, :talking_point_preferences, :ideas, :idea_ratings, :comments, :content_reports, :points_total, :points_days1, :points_days3, :points_days7, :points_days14, :points_days28, :points_days90, :last_visit, :level, :day_visits, :last_day_visit, :next_day_visit, :created_at, :updated_at, :set_following
  
end
