class Question < ActiveRecord::Base
  include LibGetTalkingPointsRatings
    
  belongs_to :team
  
  has_many :ideas, :class_name => 'Idea', :foreign_key => 'question_id', :conditions => 'is_theme = false', :order => 'order_id asc'
  has_many :unthemed_ideas, :class_name => 'Idea', :foreign_key => 'question_id', :conditions => 'is_theme = false AND parent_id IS NULL', :order => 'order_id asc'
  has_many :parked_ideas, :class_name => 'Idea', :foreign_key => 'question_id', :conditions => 'is_theme = false AND parent_id = 0', :order => 'order_id asc'	
  has_many :themed_ideas, :class_name => 'Idea', :foreign_key => 'question_id', :conditions => 'is_theme = false AND parent_id IS NOT NULL', :order => 'order_id asc'
  has_many :themes, :class_name => 'Idea', :foreign_key => 'question_id', :conditions => 'is_theme = true', :order => 'order_id asc'
  
  has_one :default_answer, :class_name => 'DefaultAnswer', :foreign_key => 'id',  :primary_key => 'default_answer_id'
    
  has_many :unrated_ideas, class_name: 'Idea', 
    finder_sql: proc { 
      %Q|SELECT ideas.* FROM "ideas" 
      LEFT OUTER JOIN idea_ratings ON ideas.id = idea_ratings.idea_id AND idea_ratings.member_id = #{self.member.id} 
      WHERE ideas.question_id = #{self.id} AND ideas.is_theme = false AND idea_ratings.id IS null
      ORDER BY id ASC|
    },
    counter_sql: proc { 
      %Q|SELECT COUNT(ideas.*) FROM "ideas" 
      LEFT OUTER JOIN idea_ratings ON ideas.id = idea_ratings.idea_id AND idea_ratings.member_id = #{self.member.id} 
      WHERE ideas.question_id = #{self.id} AND ideas.is_theme = false AND idea_ratings.id IS null|
    }


  has_many :talking_points, :dependent => :destroy

  has_many :top_talking_points, :class_name => 'TalkingPoint', :finder_sql => 
    proc { %Q|SELECT tp.id, tp.version, tp.text, tp.order_id, tp.visible, tp.updated_at, count(tpp.member_id) 
    FROM talking_points tp 
    LEFT OUTER JOIN talking_point_preferences tpp ON tp.id = tpp.talking_point_id
    WHERE tp.question_id = #{id}
    GROUP BY tp.id, tp.version, tp.text, tp.order_id, tp.visible, tp.updated_at
    ORDER BY count(tpp.member_id) DESC, tp.id DESC
    LIMIT 5| }
 
  has_many :all_talking_points, :class_name => 'TalkingPoint', :finder_sql => 
    proc { %Q|SELECT tp.id, tp.version, tp.text, tp.order_id, tp.visible, tp.updated_at, count(tpp.member_id) 
    FROM talking_points tp 
    LEFT OUTER JOIN talking_point_preferences tpp ON tp.id = tpp.talking_point_id
    WHERE tp.question_id = #{id}
    GROUP BY tp.id, tp.version, tp.text, tp.order_id, tp.visible, tp.updated_at
    ORDER BY count(tpp.member_id) DESC, tp.id DESC| }

  
  has_many :comments, :foreign_key => 'parent_id', :conditions => 'parent_type = 1', :order => 'id asc', :include => :author
  has_many :recent_comments, :class_name => 'Comment', :foreign_key => 'parent_id', :conditions => 'parent_type = 1', :limit => 3, :order => "id DESC", :include => :author
  
  has_many :answers, :order => 'id asc'
  
  validates_presence_of :text
  validates_length_of :text, :in => 12..200, :allow_blank => false
  
  attr_accessible :member_id, :status, :text, :num_answers, :anonymous, :ver, :idea_criteria, :answer_criteria, :default_answer_id, :team_id, :order_id, :talking_point_criteria, :talking_point_preferences, :inactive, :curated_tp_ids, :auto_curated
  
  attr_accessor :par_id
  attr_accessor :target_id
  attr_accessor :target_type
  attr_accessor :insert_mode
  attr_accessor :itemDestroyed
  attr_accessor :item_id
  attr_accessor :order
  attr_accessor :coms
  attr_accessor :new_coms
  attr_accessor :num_talking_points
  attr_accessor :num_new_talking_points
  attr_accessor :talking_points_to_display
  attr_accessor :comments_to_display
  attr_accessor :member
  attr_accessor :curated_talking_points_set
  attr_accessor :previousText
  attr_accessor :previousVer
  attr_accessor :previousUpdated_at
  attr_accessor :new_talking_points
  attr_accessor :new_comments
  attr_accessor :unrated_talking_points
  attr_accessor :updated_talking_points
  attr_accessor :show_new
  attr_accessor :unrated_ideas_count
  
  
  after_initialize :init
  
  def self.update_curated_talking_point_ids(question_id, tp_ids, mode, member)
    allowed,message,team_id = InitiativeRestriction.allow_actionX({:question_id => question_id}, 'curate_talking_points', member)
    if !allowed
      return false, message
    end
    
    Question.find(question_id).update_curate_fields(tp_ids,mode)  
    return true
  end
    
  def auto_curate_talking_points()
    return if self.auto_curated == false
    top_tp_ids = ActiveRecord::Base.connection.select_values(%Q|SELECT tp.id, COUNT(tpp.member_id) 
    FROM talking_points tp LEFT JOIN talking_point_preferences tpp 
    ON tp.id = tpp.talking_point_id
    WHERE tp.question_id = #{self.id}
    GROUP BY tp.id
    ORDER BY COUNT(tpp.member_id) DESC
    LIMIT 5|).collect{|id| id.to_i}.join(',')
    self.update_curate_fields(top_tp_ids,'auto')
  end
  
  def curated_talking_points
    if self.curated_talking_points_set.nil?
      # eager load the curated talking points and attach them to the questions in order as question.curated_talking_points
      self.curated_talking_points_set = []
      tp_ids = self.curated_tp_ids.nil? ? [] : self.curated_tp_ids.split(',').collect{|id| id.to_i}
      #Query for all curated TP
      talking_points = TalkingPoint.where(:id => tp_ids )

      #iterate through talking points and assign the tp to the questions in order of curated ids
      talking_points.each do |talking_point|
        self.curated_talking_points_set[ tp_ids.index(talking_point.id) ] = talking_point
      end
    end
    self.curated_talking_points_set
  end

  def archived_com_count
    if @archived_com_count.nil?
      @archived_com_count = Comment.where(:parent_id => self.id, :parent_type => 1).count
    else
      @archived_com_count
    end
  end
  
  def o_type
    1 #type for Questions
  end
  def type_text
    'question' #type for Questions
  end
  
  def comments_with_ratings(memberId)
    comments = Comment.find_by_sql([ %q|SELECT c.id,   
      SUM(up) AS up,
      SUM(down) AS down,
      (SELECT CASE WHEN up = 1 THEN 1 ELSE -1 END FROM com_ratings WHERE member_id = ? AND comment_id = c.id) AS my_vote,
      c.member_id, c.text, c.anonymous, c.created_at, c.updated_at, status, publish, par_id, sib_id, "order", target_id, target_type, i.id AS item_id
      FROM comments c 
      LEFT JOIN items AS i ON i.o_id = c.id AND i.o_type = 3
      LEFT OUTER JOIN com_ratings cr ON c.id = cr.comment_id
      WHERE i.team_id = ?
      AND o_type = 3 
      AND ? = ANY (ancestors)
      GROUP BY c.id, c.member_id, c.text, c.anonymous, c.created_at, c.updated_at, c.status, c.publish, par_id, sib_id, "order", target_id, target_type, i.id|,
      memberId, self.team_id, self.item_id ]
    )
    resources = Resource.find_all_by_comment_id( comments.collect {|c| c.id } )
    authors = Member.all(:conditions=> {:id => (comments.collect {|c| c.member_id }.uniq) })
    return comments, resources, authors
    
  end

  def bs_ideas_with_favorites(memberId)
    bs_ideas = BsIdea.find_by_sql([ %q|SELECT bsi.id, 
      (SELECT count(*) FROM bs_idea_favorites WHERE bs_idea_id = bsi.id AND favorite = true) AS num_favs,
      (SELECT favorite FROM bs_idea_favorites WHERE member_id = ? AND bs_idea_id = bsi.id) AS my_fav,
      bsi.question_id, bsi.member_id, bsi.text, bsi.created_at, bsi.updated_at, bsi.publish, i.id as item_id
      FROM bs_ideas bsi
      LEFT JOIN items AS i ON i.o_id = bsi.id AND i.o_type = 12
      WHERE question_id = ? ORDER BY num_favs|, memberId, self.id ]
    )
    priorities = BsIdeaFavoritePriority.find_by_member_id_and_question_id(memberId, self.id)
    return bs_ideas, priorities
  end
  
  def answers_with_ratings(memberId)
    Answer.find_by_sql([ %q|SELECT a.id, 
      AVG(rating) AS average, 
      COUNT(rating) AS count, 
      (SELECT rating FROM answer_ratings WHERE member_id = ? AND answer_id = a.id) AS my_vote,
      a.question_id, a.member_id, a.text, a.ver, a.created_at, a.updated_at
      FROM answers a LEFT OUTER JOIN answer_ratings ar ON a.id = ar.answer_id
      WHERE question_id = ?
      GROUP BY a.id, a.question_id, a.member_id,a.text, a.ver, a.created_at, a.updated_at|, memberId, self.id ]
    )
  end
  
  def self.update_worksheet_ratings( member, params )
    # iterate through all of the parameters
    selected_ids = []
    params.each_pair do |key,val|
      case key
        when /tp_rating/
          #logger.debug "Record the rating for #{key.match(/\d+/)[0]}"
          TalkingPointAcceptableRating.record( member, key.match(/\d+/)[0], val )
        when /preference_/
          #logger.debug "Record a preference for #{key.match(/\d+/)[0]}"
          selected_ids << key.match(/\d+/)[0]
      end 
    end
    tp_ids = params[:tp_ids].split(',')

    unrecorded_talking_point_preferences = TalkingPointPreference.update_preferred_talking_points( params[:question_id], selected_ids, tp_ids, member )
    
  end

  def update_curate_fields(tp_ids,mode)
    if tp_ids.strip != ''
      self.curated_tp_ids = tp_ids.scan(/\d+/).uniq.join(',')
      self.auto_curated = mode == 'auto' ? true : false
      self.save(:validate => false)
    else
      if self.talking_points.size>0
        self.auto_curated = true 
        self.auto_curate_talking_points()
        return
      else
        return
      end
    end

    # record curation history
    # record curation participation event
    
  end
  
protected
  def init
    self.show_new = false
  end
  
end
