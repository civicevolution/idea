class Question < ActiveRecord::Base
  include LibGetTalkingPointsRatings
    
  belongs_to :team
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
  attr_accessor :curated_talking_points_set
  attr_accessor :previousText
  attr_accessor :previousVer
  attr_accessor :previousUpdated_at
  attr_accessor :new_talking_points
  attr_accessor :new_comments
  attr_accessor :unrated_talking_points
  attr_accessor :updated_talking_points
  attr_accessor_with_default :show_new, false
  
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

  def assign_new_content
    # gets the unrated TP    
    self.new_talking_points = TalkingPoint.select('tp.*')
      .joins(" AS tp LEFT JOIN talking_point_acceptable_ratings AS tpar ON tp.id=tpar.talking_point_id AND tpar.member_id = #{self.member.id}",)
      .where("tpar.id IS NULL AND question_id = #{self.id}")
    
    self.new_talking_points.each{|tp| tp['new'] = true }
    new_tp_ids = new_talking_points.map{|tp| tp.id.to_i }
    new_tp_ids = [0] if new_tp_ids.size == 0
    # now there may be some TP that have been updated since I rated them
    updated_talking_points = TalkingPoint.where("question_id = :question_id AND version > 1 AND updated_at >= :last_visit AND id NOT IN (:new_tp_ids)",
      :question_id => self.id, :new_tp_ids => new_tp_ids, :last_visit => member.question_last_visit_ts)

    updated_talking_points.each{|tp| tp['updated'] = true }

    self.new_talking_points += updated_talking_points

    self.new_comments = Comment.includes(:author).where("question_id = :question_id AND created_at >= :last_visit", :question_id => self.id, :last_visit => member.question_last_visit_ts)
    self.new_comments.each{|com| com['new'] = true }
    
  
    tps_i_need = self.new_comments.map{ |c| c.parent_type == 13 ? c.parent_id : nil}.compact.uniq - self.new_talking_points.map(&:id)

    if tps_i_need.size > 0
      needed_tps = TalkingPoint.find(tps_i_need)
      TalkingPoint.add_my_ratings_and_prefs(needed_tps,self.member)
      self.new_talking_points = self.new_talking_points + needed_tps
    end  
    
    # Do I need to load any parent comments to give context to a child comment?
    # get all the com parent_ids
    com_ids_i_need = self.new_comments.map{ |c| c.parent_type == 3 ? c.parent_id : nil}.compact.uniq - self.new_comments.map(&:id)

    if com_ids_i_need.size > 0
      self.new_comments = self.new_comments + Comment.find(com_ids_i_need)
    end  
    
    # Assign child comments to parent tp and coms
    self.new_comments.each do |c|
      if c.parent_type == 13
        logger.debug "assign new coms to TP is: #{c.parent_id}"
        tp = self.new_talking_points.detect{|tp| tp.id == c.parent_id }
        tp['comments'] ||= []
        tp['comments'].push(c)
      elsif c.parent_type == 3
        com = self.new_comments.detect{|com| com.id == c.parent_id }
        com['comments'] ||= []
        com['comments'].push(c)
      end
    end

    self.show_new = self.new_talking_points.size > 0 || self.new_comments.size > 0 
  end
  
  def remaining_talking_points(ids)
    # process ids to make sure they are just numbers
    ids = ids.map{|i| i.to_i }
    ids = [0] if ids.size == 0
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
    ids = [0] if ids.size == 0
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

  def remaining_new_comments(ids, last_visit_ts)
    # process ids to make sure they are just integers
    ids = ids.map{|i| i.to_i }
    ids = [0] if ids.size == 0
    Comment.includes(:author).where("parent_id = :question_id AND parent_type = 1 AND comments.id NOT IN (:current_com_ids) AND comments.created_at >= :last_visit", :question_id => self.id, :current_com_ids => ids, :last_visit => last_visit_ts ).order('id ASC')
  end

  def remaining_comments(ids)
    # process ids to make sure they are just integers
    ids = ids.map{|i| i.to_i }
    ids = [0] if ids.size == 0
    Comment.includes(:author).where("parent_id = :question_id AND parent_type = 1 AND comments.id NOT IN (:current_com_ids)", :question_id => self.id, :current_com_ids => ids).order('id ASC')
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
  
  
end
