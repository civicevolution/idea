class Question < ActiveRecord::Base
  
  has_many :item_diffs, :foreign_key => 'o_id',  :dependent => :destroy
  has_one :item
  
  validates_presence_of :text
  validates_length_of :text, :in => 5..200, :allow_blank => false
  
  #validate_on_create :check_team_access
  #validate_on_update :check_item_edit_access
    
  after_create :create_item_record
  after_destroy :delete_item_record
  before_destroy :check_item_delete_access
  before_create :set_version
  after_find :set_team_after_find
    
  #before_validation :check_team_access, :create_item_record
  
  #debugger

  attr_accessor :par_id
  attr_accessor :target_id
  attr_accessor :target_type
  attr_accessor :team_id  
  attr_accessor :insert_mode
  attr_accessor :itemDestroyed
  attr_accessor :item_id
  attr_accessor :order

  
  # code required to record revision history for this item
  def set_version 
    self.ver = 0
  end
  
  def set_team_after_find
    return if self.nil? || self.id.nil?
    item = Item.find_by_o_id_and_o_type(self.id, 1) 
    self.team_id = item.team_id
    self.item_id = item.id
    
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
  
  
end
