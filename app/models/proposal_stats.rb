class ProposalStats < ActiveRecord::Base
  attr_accessible :team_id, :proposal_views, :question_views, :participants, :friend_invites, :followers, :endorsements, :talking_points, :talking_point_edits, :talking_point_ratings, :talking_point_preferences, :comments, :content_reports, :proposal_views_base, :question_views_base, :points_total, :points_days1, :points_days3, :points_days7, :points_days14, :points_days28, :points_days90
end
