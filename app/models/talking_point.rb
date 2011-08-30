class TalkingPoint < ActiveRecord::Base
  include LibGetTalkingPointsRatings
  
  belongs_to :question
	has_many :talking_point_acceptable_ratings
  has_many :talking_point_preferences
	has_many :talking_point_versions          
	has_many :comments, :foreign_key => 'parent_id', :conditions => 'parent_type = 13', :order => 'id asc'
  
  attr_accessor_with_default :preference_votes, 0
  attr_accessor_with_default :rating_votes, [0,0,0,0,0]
  attr_accessor :my_preference
  attr_accessor :my_rating
  attr_accessor_with_default :coms, 0
  attr_accessor_with_default :new_coms, 0
  
  attr_accessor :member
  attr_accessor :team_id
   
  before_validation :check_initiative_restrictions, :on=>:create
  after_save :log_team_content
  
  # temporary validation to prevent posting
  #validates_length_of :text, :in => 500..1500, :allow_blank => false
  
  def check_initiative_restrictions
    #logger.debug "TalkingPoint.check_initiative_restrictions"
    self.member_id ||= self.member.id
    self.version ||= 1
    allowed,message, self.team_id = InitiativeRestriction.allow_actionX({:question_id=>self.question_id}, 'contribute_to_proposal', self.member)
    if !allowed
      errors.add(:base, "Sorry, you do not have permission to add a talking point.") 
      return false
    end
    true
  end
  
  def log_team_content
    # log this item into the team_content_logs
    TeamContentLog.new(:team_id=>self.team_id, :member_id=>self.member_id, :o_type=>self.o_type, :o_id=>self.id, :processed=>false).save
  end  
  
  def team
    Team.joins(:questions).where('questions.id = ?', self.question_id).first
  end
  

  def self.com_counts(talking_point_ids, last_visit_ts)
    return [] if talking_point_ids.size == 0
    ActiveRecord::Base.connection.select_all(
    %Q|select talking_point_id,
    (select count(id) from comments where parent_type=13 and parent_id = talking_point_id) AS coms,
    (SELECT count(id) from comments where parent_type=13 and parent_id = talking_point_id AND created_at > '#{last_visit_ts}') AS new_coms
    FROM ( VALUES #{ talking_point_ids.map{ |id| "(#{id})" }.join(',') } ) AS t (talking_point_id)|
    )
  end

  def self.get_and_assign_stats( question, talking_points_to_display, member )
    
    question.talking_points_to_display = talking_points_to_display
    talking_point_ids = []
    comment_member_ids = []
    question.talking_points_to_display.each do |tp| 
      talking_point_ids << tp.id
    end
    
    tpp = TalkingPointPreference.sums(talking_point_ids)
    tpr = TalkingPointAcceptableRating.sums(talking_point_ids)
    my_preferences = TalkingPointPreference.my_votes(talking_point_ids, member.id)
    my_ratings = TalkingPointAcceptableRating.my_votes(talking_point_ids, member.id)
    talking_point_coms = TalkingPoint.com_counts(talking_point_ids, member.last_visit_ts)

    self.assign_stats( 
      :questions => [question],
      :talking_point_coms => talking_point_coms,
      :tpp => tpp,
      :tpr => tpr, 
      :my_preferences => my_preferences,
      :my_ratings => my_ratings
    )
  end
  
  
  def self.assign_stats stats
    
    stats[:question_coms] ||= []

    stats[:questions].each do |q| 
      qcom = stats[:question_coms].detect{|qc| qc['ques_id'].to_i == q.id}
      if !qcom.nil?
        q.coms = qcom['coms'].to_i
        q.new_coms = qcom['new_coms'].to_i
        q.num_talking_points = qcom['num_talking_points'].to_i
        q.num_new_talking_points = qcom['num_new_talking_points'].to_i
      end

      q.talking_points_to_display.each do |tp| 
        pref = stats[:tpp].detect{|p| p.talking_point_id == tp.id}
        tp.preference_votes = pref.count.to_i unless pref.nil? 
        
        tp.rating_votes = [0,0,0,0,0]
        stats[:tpr].select{|rec| rec.talking_point_id == tp.id}.each do |r|
          tp.rating_votes[r.rating-1] = r.count.to_i
        end
        
        my_pref = stats[:my_preferences].detect{|p| p.talking_point_id == tp.id}
        tp.my_preference = my_pref.nil? ? false : true 
        
        my_rating = stats[:my_ratings].detect{|r| r.talking_point_id == tp.id}
        tp.my_rating = my_rating.rating.to_i unless my_rating.nil?

        tpcom = stats[:talking_point_coms].detect{|tpc| tpc['talking_point_id'].to_i == tp.id}
        if !tpcom.nil?
          tp.coms = tpcom['coms'].to_i
          tp.new_coms = tpcom['new_coms'].to_i
        else
          tp.coms = 0
          tp.new_coms = 0
        end
      end
    end
  end
  
  
  def o_type
    13 #type for talking point
  end
  
  def type_text
    'talking point' #type for talking point
  end
  
    
end
