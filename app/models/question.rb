class Question < ActiveRecord::Base
  include LibGetTalkingPointsRatings
    
  belongs_to :team
  has_many :talking_points, :dependent => :destroy
 
  has_many :top_talking_points, :class_name => 'TalkingPoint', :finder_sql => 
    proc { %Q|SELECT tp.id, tp.version, tp.text, tp.updated_at, count(tpp.member_id) 
    FROM talking_points tp 
    LEFT OUTER JOIN talking_point_preferences tpp ON tp.id = tpp.talking_point_id
    WHERE tp.question_id = #{id}
    GROUP BY tp.id, tp.version, tp.text, tp.updated_at
    ORDER BY count(tpp.member_id) DESC, id DESC
    LIMIT 5| }
  
  has_many :comments, :foreign_key => 'parent_id', :conditions => 'parent_type = 1', :order => 'id asc', :include => :author
  has_many :recent_comments, :class_name => 'Comment', :foreign_key => 'parent_id', :conditions => 'parent_type = 1', :limit => 3, :order => "id DESC", :include => :author
  
  
  
  has_one :answer
  
  validates_presence_of :text
  validates_length_of :text, :in => 5..200, :allow_blank => false
  
  #validate_on_create :check_team_access
  #validate_on_update :check_item_edit_access
    
  #after_create :create_item_record
  #after_destroy :delete_item_record
  #before_destroy :check_item_delete_access
  before_create :set_version
    
  #before_validation :check_team_access, :create_item_record
  
  #before_validation :check_initiative_restrictions, :on=>:create
  #def check_initiative_restrictions
  #  self.publish = true unless !self.member.confirmed
  #  #logger.debug "Comment.check_initiative_restrictions"
  #  self.member_id ||= self.member.id
  #  allowed,message, self.team_id = InitiativeRestriction.allow_actionX({:parent_id=>self.parent_id, :parent_type => self.parent_type}, 'contribute_to_proposal', self.member)
  #  if !allowed
  #    errors.add_to_base("Sorry, you do not have permission to add a question.") 
  #    return false
  #  end
  #  true
  #end
  
  
  
  
  
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
  attr_accessor :member
  

  def remaining_talking_points(ids)
    # process ids to make sure they are just numbers
    ids = ids.map{|i| i.to_i }
    TalkingPoint.find_by_sql([
      %Q|SELECT tp.id, tp.version, tp.text, tp.updated_at, count(tpar.member_id) 
      FROM talking_points tp 
      LEFT OUTER JOIN talking_point_acceptable_ratings tpar ON tp.id = tpar.talking_point_id
      WHERE tp.question_id = ?
      AND tp.id NOT IN ( #{ ids.join(',') } )
      GROUP BY tp.id, tp.version, tp.text, tp.updated_at
      ORDER BY count(tpar.member_id) DESC, id DESC|,self.id])
  end

  def remaining_new_talking_points(ids, last_visit_ts)
    # process ids to make sure they are just numbers
    ids = ids.map{|i| i.to_i }
    TalkingPoint.find_by_sql([
      %Q|SELECT tp.id, tp.version, tp.text, tp.updated_at, count(tpar.member_id) 
      FROM talking_points tp 
      LEFT OUTER JOIN talking_point_acceptable_ratings tpar ON tp.id = tpar.talking_point_id
      WHERE tp.question_id = ?
      AND tp.id NOT IN ( #{ ids.join(',') } )
      AND tp.updated_at >= '#{last_visit_ts}'
      GROUP BY tp.id, tp.version, tp.text, tp.updated_at
      ORDER BY count(tpar.member_id) DESC, id DESC|,self.id])
  end


  def remaining_comments(ids)
    # process ids to make sure they are just numbers
    ids = ids.map{|i| i.to_i }
    Comment.find_by_sql([
      %Q|SELECT id, member_id, anonymous, status, text, created_at, updated_at, publish, parent_type, parent_id 
      FROM comments
      WHERE parent_type = 1 
      AND parent_id = ?
      AND id NOT IN ( #{ ids.join(',') } )
      ORDER BY id ASC|,self.id])
  end


  
  # code required to record revision history for this item
  def set_version 
    self.ver = 0
  end
  
  after_save :create_history_record

  def store_initial_values
    # save the previous state, this must be called manually because I don't want to call it everytime I read an answer record
    # call store_initial_values after instantiating the object, but before I add the new parameters
    self.previousText = self.text || ''
    self.previousVer = self.ver || 0
    self.previousUpdated_at = self.updated_at || nil
  end

  attr_accessor :previousText
  attr_accessor :previousVer
  attr_accessor :previousUpdated_at

  @created_history_record = false

  def create_history_record
    return if @created_history_record # only create record once per save. update ver attribute will revisit here
    diff = ItemDiff.new(:item => self)
    diff.save!
    @created_history_record = true
    self.update_attribute :ver, diff.ver  # update the item ver
  end
  # end of code for revision history  
  
  
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
  
  #def answers_with_ratings(memberId)
  #  AnswerRating.find_by_sql([ %q|SELECT a.id, 
  #    AVG(rating) AS average, 
  #    COUNT(rating) AS count, 
  #    (SELECT rating FROM answer_ratings WHERE member_id = ? AND answer_id = a.id) AS my_vote,
  #    a.question_id, a.member_id, a.text, a.ver, a.created_at, a.updated_at
  #    FROM answers a LEFT OUTER JOIN answer_ratings ar ON a.id = ar.answer_id
  #    WHERE question_id = ?
  #    GROUP BY a.id, a.question_id, a.member_id,a.text, a.ver, a.created_at, a.updated_at|, memberId, self.id ]
  #  )
  #end
  
  
  def self.com_counts(question_ids, last_visit_ts)
    ActiveRecord::Base.connection.select_all(
      %Q|select ques_id,
      (select count(id) from comments where parent_type=1 and parent_id = ques_id) AS coms,
      (SELECT count(id) from comments where parent_type=1 and parent_id = ques_id AND created_at > '#{last_visit_ts}') AS new_coms,
      (select count(id) from talking_points where question_id = ques_id) AS num_talking_points,
      (SELECT count(id) from talking_points where question_id = ques_id AND updated_at > '#{last_visit_ts}') AS num_new_talking_points
      FROM ( VALUES #{ question_ids.map{ |id| "(#{id})" }.join(',')	 } ) AS q (ques_id)|
    )
  end
  
  
end
