class TalkingPoint < ActiveRecord::Base
  include LibGetTalkingPointsRatings
  
  belongs_to :question
	has_many :talking_point_acceptable_ratings
  has_many :talking_point_preferences
	has_many :versions, :class_name => 'TalkingPointVersion', :order => 'version DESC'
	has_many :comments, :foreign_key => 'parent_id', :conditions => 'parent_type = 13', :order => 'id asc'

  scope :sibling_talking_points, lambda { |id| select('id, text').where("question_id = (SELECT question_id FROM talking_points WHERE id = ?)", id) }
  
  attr_accessible :question_id, :member_id, :version, :text, :order_id, :visible, :member
  
  attr_accessor :preference_votes
  attr_accessor :rating_votes
  attr_accessor :my_preference
  attr_accessor :my_rating
  attr_accessor :coms
  attr_accessor :new_coms
  
  attr_accessor :member
  attr_accessor :team_id
  attr_accessor :selected
  attr_accessor :is_new
  attr_accessor :tp_comments
   
  before_validation :check_initiative_restrictions#, :on=>:create
  before_create :set_member_id
  before_update :check_edit_privilege
  validate :check_length
  
  after_save :log_team_content
  around_update :update_version
  after_create :check_auto_curate
  
  after_initialize :init

  def check_length
    @question = Question.find(self.question_id)
    range = @question.talking_point_criteria
    range = range.match(/(\d+)..(\d+)/)
    length = text.scan(/\S/).size
    errors.add(:text, "must be at least #{range[1]} characters") unless length >= range[1].to_i
    errors.add(:text, "must be no longer than #{range[2]} characters") unless length <= range[2].to_i
  end
  
  def check_edit_privilege
    logger.debug "Does this user have privilege to edit this talking point"
    # either in team_registrations or a current or previous author of this TP
    cur_tp_member_id = self.member_id
    self.member_id = self.member.id
    
    allowed,message,team_id = InitiativeRestriction.allow_actionX({:talking_point_id => self.id, :tp_member_id => cur_tp_member_id}, 'edit_talking_point', self.member)

    if allowed
      return true
    else
      errors.add(:base, message) 
      return false
    end
  end

  def set_member_id
    self.member_id = self.member.id
  end
  
  def update_version
    old_tp = TalkingPoint.find(self.id)
    yield
    TalkingPointVersion.create( :talking_point_id => self.id, :member_id => old_tp.member_id, :version => old_tp.version, :text => old_tp.text )
  end
  
  # temporary validation to prevent posting
  #validates_length_of :text, :in => 500..1500, :allow_blank => false
  
  def check_initiative_restrictions
    #logger.debug "TalkingPoint.check_initiative_restrictions"
    self.version = self.version.nil? ? 1 : self.version + 1
    allowed,message, self.team_id = InitiativeRestriction.allow_actionX({:question_id=>self.question_id}, 'contribute_to_proposal', self.member)
    if !allowed
      errors.add(:base, "#{message} - you do not have permission to add a talking point") 
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
  

  def self.com_counts(talking_point_ids)
    return [] if talking_point_ids.size == 0
    ActiveRecord::Base.connection.select_all(
    %Q|select talking_point_id,
    (select count(id) from comments where parent_type=13 and parent_id = talking_point_id) AS coms
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

    talking_point_coms = TalkingPoint.com_counts(talking_point_ids)

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
  
  def self.add_my_ratings_and_prefs(talking_points, member)
    #debugger
    my_ratings = TalkingPointAcceptableRating.my_votes(talking_points.map(&:id), member.id)
    my_preferences = TalkingPointPreference.my_votes(talking_points.map(&:id), member.id)
    talking_points.each do |tp| 
      my_rating = my_ratings.detect{|r| r.talking_point_id == tp.id}
      tp.my_rating = my_rating.rating.to_i unless my_rating.nil?
      my_pref = my_preferences.detect{|p| p.talking_point_id == tp.id}
      tp.my_preference = my_pref.nil? ? false : true 
    end
  end
  
  def o_type
    13 #type for talking point
  end
  
  def type_text
    'talking point' #type for talking point
  end

  def init_stats(member)
    self.member = member
    ratings = TalkingPointAcceptableRating.select('count(member_id), rating').where(['talking_point_id = ?', self.id ]).group('rating')

    self.rating_votes = [0,0,0,0,0]
    ratings.each do |r|
      self.rating_votes[r.rating-1] = r.count.to_i
    end

    self.my_rating = ActiveRecord::Base.connection.select_value("SELECT rating FROM talking_point_acceptable_ratings WHERE talking_point_id = #{self.id} AND member_id = #{self.member.id}")
    self.my_rating = self.my_rating.to_i unless self.my_rating.nil?
    self.my_preference = TalkingPointPreference.where(:member_id => self.member.id, :talking_point_id => self.id).exists?
    self.preference_votes = TalkingPointPreference.where(:talking_point_id => self.id).count
    # of preferences
    self.new_coms = Comment.where("parent_type = 13 AND parent_id = :id AND created_at >= :last_visit", :id => self.id, :last_visit => self.member.question_last_visit_ts).count
    self.coms = Comment.where("parent_type = 13 AND parent_id = :id", :id => self.id).count
  end
  
protected
  def check_auto_curate
    if @question.auto_curated
      @question.auto_curate_talking_points()
    end
  end
  
  def init
    self.preference_votes = 0
    self.rating_votes = [0,0,0,0,0]
    self.coms = 0
    self.new_coms = 0
    self.selected = false
  end  
  
  
end
